// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.16;

contract NotesContract {
    uint256 public notesCount;

    struct Notes {
        uint256 id;
        string noteTitle;
        string noteContent;
        uint256 timeStamp;
    }

    mapping(uint256 => Notes) public notes;

    event NoteAdded(uint256 _id);
    event NoteDeleted(uint256 _id);
    event NoteEdited(uint256 _id);

    constructor() public {
        notesCount = 0;
    }

    function addNote(
        string memory _noteTitle,
        string memory _noteContent,
        uint256 timeStamp
    ) public {
        notes[notesCount] = Notes(
            notesCount,
            _noteTitle,
            _noteContent,
            timeStamp
        );
        emit NoteAdded(notesCount);
        notesCount++;
    }

    function deleteNote(uint256 _id) public {
        delete notes[_id];
        notesCount--;
        emit NoteDeleted(_id);
    }

    function editNote(
        uint256 _id,
        string memory _noteTitle,
        string memory _noteContent
    ) public {
        notes[_id] = Notes(_id, _noteTitle, _noteContent, notes[_id].timeStamp);
        emit NoteAdded(_id);
    }
}
