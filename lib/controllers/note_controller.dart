import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:notetaking_dapp/models/note.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class NoteController extends ChangeNotifier {
  List<Note> notes = [];
  bool isLoading = true;
  int noteCount;
  final String _rpcUrl = "http://127.0.0.1:7545";
  final String _wsUrl = "ws://127.0.0.1:7545/";

  final String _privateKey =
      "e3beb61794a259037a8ca3379f15d61a82e9bb631ba248ffe14283fdc90c04c8";

  Web3Client _client;
  String _abiCode;

  Credentials _credentials;
  EthereumAddress _contractAddress;
  EthereumAddress _ownAddress;
  DeployedContract _contract;

  ContractFunction _notesCount;
  ContractFunction _notes;
  ContractFunction _addNote;
  ContractFunction _deleteeNote;
  ContractFunction _editNote;
  ContractEvent _noteAddedEvent;
  ContractEvent _noteDeletedEvent;

  NoteController() {
    init();
  }

  init() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    await getAbi();
    await getCreadentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    String abiStringGile = await rootBundle
        .loadString("contracts/build/contracts/NotesContract.json");
    var jsonAbi = jsonDecode(abiStringGile);
    _abiCode = jsonEncode(jsonAbi['abi']);
    _contractAddress =
        EthereumAddress.fromHex(jsonAbi["networks"]["5777"]["address"]);
  }

  Future<void> getCreadentials() async {
    _credentials = await _client.credentialsFromPrivateKey(_privateKey);
    _ownAddress = await _credentials.extractAddress();
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "NotesContract"), _contractAddress);
    _notesCount = _contract.function("notesCount");
    _notes = _contract.function("notes");
    _addNote = _contract.function("addNote");
    _deleteeNote = _contract.function("deleteNote");
    _editNote = _contract.function("editNote");

    _noteAddedEvent = _contract.event("NoteAdded");
    _noteDeletedEvent = _contract.event("NoteDeleted");
    await getNotes();
  }

  getNotes() async {
    List notesList = await _client
        .call(contract: _contract, function: _notesCount, params: []);
    BigInt totalNotes = notesList[0];
    noteCount = totalNotes.toInt();
    notes.clear();
    for (int i = 0; i < noteCount; i++) {
      var temp = await _client.call(
          contract: _contract, function: _notes, params: [BigInt.from(i)]);
      if (temp[1] != "")
        notes.add(
          Note(
            id: temp[0].toString(),
            title: temp[1],
            body: temp[2],
            created:
                DateTime.fromMillisecondsSinceEpoch(temp[3].toInt() * 1000),
          ),
        );
    }
    isLoading = false;
    notifyListeners();
  }

  addNote(Note note) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _addNote,
        parameters: [
          note.title,
          note.body,
          BigInt.from(note.created.millisecondsSinceEpoch),
        ],
      ),
    );
    await getNotes();
  }

  deleteNote(int id) async {
    isLoading = true;
    notifyListeners();
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _deleteeNote,
        parameters: [BigInt.from(id)],
      ),
    );
    await getNotes();
  }

  editNote(Note note) async {
    isLoading = true;
    notifyListeners();
    print(BigInt.from(int.parse(note.id)));
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: _editNote,
        parameters: [BigInt.from(int.parse(note.id)), note.title, note.body],
      ),
    );
    await getNotes();
  }
}
