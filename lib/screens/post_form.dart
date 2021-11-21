import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingpo_game/constant.dart';
import 'package:ingpo_game/models/api_response.dart';
import 'package:ingpo_game/services/post_service.dart';
import 'package:ingpo_game/services/user_service.dart';
import 'package:ingpo_game/models/post.dart';

import 'login.dart';

class PostForm extends StatefulWidget {
  // const PostForm({ Key? key }) : super(key: key);
  final Post? post;
  final String? head;

  PostForm({this.post, this.head});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _txtControllerBody = TextEditingController();
  TextEditingController _txtControllerTitle = TextEditingController();
  bool _loading = false;
  File? _imageFile;
  final _picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _createPost() async {
    String? image = _imageFile == null ? null : getStringImage(_imageFile);
    ApiResponse response = await createPost(
        _txtControllerTitle.text, _txtControllerBody.text, image);

    if (response.error == null) {
      Navigator.of(context).pop();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  //edit post
  void _editPost(int postId) async {
    ApiResponse response = await editPost(
        postId, _txtControllerTitle.text, _txtControllerBody.text);
    if (response.error == null) {
      Navigator.of(context).pop();
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  @override
  void initState() {
    if (widget.post != null) {
      _txtControllerTitle.text = widget.post!.title ?? '';
      _txtControllerBody.text = widget.post!.body ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.head}'),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
            key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(15),
                children: [
                  widget.post != null
                    ? SizedBox()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        decoration: BoxDecoration(
                            image: _imageFile == null
                                ? null
                                : DecorationImage(
                                    image: FileImage(_imageFile ?? File('')),
                                    fit: BoxFit.cover)),
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.image,
                                size: 50, color: Colors.black38),
                            onPressed: () {
                              getImage();
                            },
                          ),
                        ),
                      ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                      controller: _txtControllerTitle,
                      keyboardType: TextInputType.text,
                      validator: (val) =>
                          val!.isEmpty ? 'Post Title is required' : null,
                      decoration: InputDecoration(
                          hintText: "Post title..",
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black38))),
                    ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                      controller: _txtControllerBody,
                      keyboardType: TextInputType.multiline,
                      maxLines: 7,
                      validator: (val) =>
                          val!.isEmpty ? 'Post Body is required' : null,
                      decoration: InputDecoration(
                          hintText: "Post body..",
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black38))),
                    ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1),
                  child: fTextButton('Post', () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _loading = !_loading;
                      });
                      if (widget.post == null) {
                        _createPost();
                      } else {
                        _editPost(widget.post!.id ?? 0);
                      }
                    }
                  }),
                ),
                ],
              ),
            ),
    );
  }
}
