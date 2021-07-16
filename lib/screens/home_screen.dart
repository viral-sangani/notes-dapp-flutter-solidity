import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notetaking_dapp/controllers/note_controller.dart';
import 'package:notetaking_dapp/models/note.dart';
import 'package:notetaking_dapp/screens/notes_details_screen.dart';
import 'package:notetaking_dapp/screens/notes_edit_screen.dart';
import 'package:notetaking_dapp/utils/themes.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NoteController noteController;
  List<Note> notes;
  @override
  Widget build(BuildContext context) {
    noteController = Provider.of<NoteController>(context);
    notes = noteController.notes;
    print(noteController.isLoading);
    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NotesEditScreen(),
            ),
          );
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Color(0xFF80DFEA),
            borderRadius: BorderRadius.circular(200),
          ),
          child: Center(
            child: Text(
              "+",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      backgroundColor: ColorConstant.bg,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: noteController.isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Notes",
                            style: GoogleFonts.montserrat(
                              fontSize: 40,
                              color: Colors.grey[100],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: ColorConstant.bgAccent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Expanded(
                        child: new StaggeredGridView.countBuilder(
                          crossAxisCount: 2,
                          itemCount: notes.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isThirdNote = (index + 1) % 3 == 0;
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => NotesDetailsScreen(
                                      note: notes[index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ColorConstant.notesBg[index % 5],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.all(25),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notes[index].title,
                                      style: GoogleFonts.montserrat(
                                        fontSize: isThirdNote ? 32 : 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "May 21, 2021",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: ColorConstant
                                            .noteTextBg[index % 5]
                                            .withOpacity(1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          staggeredTileBuilder: (int index) =>
                              new StaggeredTile.count(
                                  (index + 1) % 3 == 0 ? 2 : 1, 1),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
