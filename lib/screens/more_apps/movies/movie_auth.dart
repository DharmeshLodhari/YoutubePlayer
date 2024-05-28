import 'package:Slydo/screens/more_apps/movies/models/MovieDetailItem.dart';
import 'package:Slydo/services/auth.dart';

import 'models/MovieItem.dart';
import 'models/PartialMovieItem.dart';

class MovieAuthService extends AuthService {
  Future<List<String>> getLocation() async {
    final List<String> list = [
      "Lagos",
      "Kano",
      "Ibadan",
      "Benin City",
      "Abuja"
    ];
    return list;
  }

  Future<List<MovieItem>> getMovieList() async {
    final propertyItem = List.generate(
      10,
      (index) => MovieItem.fromJson({
        "id": 1,
        "name": "The Cloud Of Northland",
        "poster": "https://m.media-amazon.com/images/I/A1o+mUmviOL._SS500_.jpg",
        "genre": "Action",
        "year": "2020",
        "price": "34.00",
        "currency": "NGN",
        "rating": "7.8"
      }),
    );
    await Future.delayed(const Duration(seconds: 1));
    return propertyItem;
  }

  Future<List<PartialMovieItem>> getPartialMovieList() async {
    final List<String> imgList = [
      "https://i.ytimg.com/vi/Jd6FuSkDkmU/maxresdefault.jpg",
      "https://occ-0-92-1723.1.nflxso.net/dnm/api/v6/X194eJsgWBDE2aQbaNdmCXGUP-Y/AAAABfyfVmzawFldwvYxxIfCr5xg_lsH9NZoQMVve9upZzDxlhuUaeJIMvwH8HiEvISV6X8lJ3CtsOst33FYzzearPngMTxq1CI90Rz9UCPJ-uu8c4QegoJm-lzHI-uC.jpg",
      "https://deythere.com/wp-content/uploads/2019/12/zero-hour.png",
      "https://m.media-amazon.com/images/M/MV5BMDljNjk3MWYtYjA4Zi00MDUyLWI2ZmUtOTQ3ZTI4YWUxYTI5XkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_.jpg",
      "https://www.bellanaija.com/wp-content/uploads/2017/01/Arbitration2-723x1024.jpg",
      "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg"
    ];
    final movieItem = imgList
        .map(
          (image) => PartialMovieItem.fromJson({"id": 1, "poster": image}),
        )
        .toList();
    await Future.delayed(const Duration(seconds: 1));
    return movieItem;
  }

  Future<MovieDetailItem> getMovie() async {
    final dummyData = {
      "name": "DAWN OF THUNDER",
      "category": "Comedy",
      "year": "2020",
      "time": "1h20m",
      "viewing_rating": "15+",
      "rating": "7.8",
      "price": "34.00",
      "currency": "NGN",
      "description":
          "Excepteur sint occaecat cupidatat non proident,sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pa.",
      "starring":
          "Callan McAuliffe, Lorraine Nicholson, Daniel Eric Gold, Allyson Pratt ...",
      "video":
          "https://rawcdn.githack.com/BlackStriker99/slydo-mock-data/e4199d196b558eb45681c194e3ce2734486e38aa/dawn-of-thunder.mp4?raw=true",
      "poster":
          "https://c1.iggcdn.com/indiegogo-media-prod-cld/image/upload/c_fill,f_auto,h_630,w_1200/v1506734779/wcsmythcukjuuglotjvb.jpg"
    };

    final MovieDetailItem movie = MovieDetailItem.fromJson(dummyData);
    await Future.delayed(const Duration(seconds: 1));
    return movie;
  }

  Future<void> addToWishList() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return;
  }
}
