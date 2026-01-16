import 'package:passion_tree_frontend/features/reflection_tree/domain/album_model.dart';

class AlbumData {
  static List<Album> albums = [
    Album(
      title: "Science",
      subtitle: "Edited 10 minutes ago",
      image: 'assets/images/albumcover/science.jpg',
      items: [
        AlbumItem(
        subjectName: "Biology101",
        lastEdited: "Edited 40 minutes ago",
        status: "Growing",
        ),
        AlbumItem(
        subjectName: "Microbio",
        lastEdited: "Edited 2 weeks ago",
        status: "Fading",
        ),
        AlbumItem(
        subjectName: "Genetics",
        lastEdited: "Edited 3 weeks ago",
        status: "Dying",
        ),
        AlbumItem(
        subjectName: "DNA",
        lastEdited: "Edited 1 month ago",
        status: "Died",
        ),
      ]
    ),
    Album(
      title: "Languages",
      subtitle: "Edited 1 hour ago",
      image: 'assets/images/albumcover/languages.jpg'
    ),
    Album(
      title: "University",
      subtitle: "Edited 1 day ago",
      image: 'assets/images/albumcover/university.jpg'
    ),
    Album(
      title: "Math",
      subtitle: "Edited 3 days ago",
      image: 'assets/images/albumcover/math.jpeg'
    ),
    Album(
      title: "Chemichejai",
      subtitle: "Edited 3 days ago",
      image: 'assets/images/albumcover/chemichejai.jpg'
    ),
    Album(
      title: "Coding",
      subtitle: "Edited 3 days ago",
      image: 'assets/images/albumcover/coding.jpg'
    ),
    Album(
      title: "Physics",
      subtitle: "Edited 3 days ago",
      image: 'assets/images/albumcover/physics.jpg'
    ),
    Album(
      title: "History",
      subtitle: "Edited 3 days ago",
      image: 'assets/images/albumcover/history.jpg'
    )
  ];
}