import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komikcast/bloc/favorite_bloc.dart';
import 'package:komikcast/bloc/favorite_sort_bloc.dart';
import 'package:komikcast/bloc/history_bloc.dart';
import 'package:komikcast/components/card/comictype.dart';
import 'package:komikcast/components/image_shimmer.dart';
import 'package:komikcast/components/text/sub_header_text.dart';
import 'package:komikcast/data/pro_data.dart';

class FavoriteTabPage extends StatefulWidget {
  @override
  _FavoriteTabPageState createState() => _FavoriteTabPageState();
}

class _FavoriteTabPageState extends State<FavoriteTabPage>
    with AutomaticKeepAliveClientMixin {
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SubHeader(
              text: 'last readed',
              width: width,
              onPressed: () => Modular.to.pushNamed('/lastreaded'),
            ),
            BlocBuilder<HistoryBloc, List<Map>>(
              builder: (context, state) =>
                  RecentList(width: width, data: state),
            ),
            BlocBuilder<FavoriteBloc, List<Map>>(
              builder: (context, state) => SubHeader(
                text: 'your favorite',
                width: width,
                withNext: false,
                action: Text(
                  '[${state.length}]',
                  style: GoogleFonts.heebo(
                    color: Colors.blue,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            FavoriteList(width: width),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class FavoriteList extends StatelessWidget {
  FavoriteList({
    Key key,
    @required this.width,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: BlocBuilder<FavoriteSortBloc, String>(
        builder: (ctx, sort) => BlocBuilder<FavoriteBloc, List<Map>>(
          builder: (context, state) {
            state = sort == 'desc' ? state.reversed.toList() : state;
            return Wrap(
              spacing: 8.0,
              children: state
                  .map(
                    (e) => ListItemGrid(
                      width: width,
                      image: e['image'],
                      type: 'manga',
                      title: e['title'],
                      chapter: e['chapterName'],
                      mangaId: e['mangaId'],
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}

class ListItemGrid extends StatelessWidget {
  const ListItemGrid({
    Key key,
    @required this.width,
    this.image,
    this.title,
    this.type,
    this.chapter,
    this.mangaId,
    this.rating,
  }) : super(key: key);

  final double width;
  final String image, type, title, chapter, mangaId, rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () => Modular.to.pushNamed('/detailmanga', arguments: {
              'image': image,
              'title': title,
              'linkId': mangaId,
            }),
            child: Container(
              width: (width * .5) - 12.0,
              alignment: Alignment.center,
              child: Container(
                // padding: EdgeInsets.only(left: ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        image == null
                            ? Container(
                                width: (width * .5) - 12.0,
                                height: width * .62,
                                color: Theme.of(context)
                                    .textSelectionHandleColor
                                    .withOpacity(.2),
                              )
                            : CachedNetworkImage(
                                imageUrl: image,
                                fit: BoxFit.cover,
                                width: (width * .5) - 12.0,
                                height: width * .62,
                                useOldImageOnUrlChange: true,
                                placeholder: (_, __) => ImageShimmerPlaceHolder(
                                  width: (width * .5) - 12.0,
                                  height: width * .62,
                                ),
                              ),
                        Positioned(
                          bottom: 8.0,
                          left: 8.0,
                          child: ComicTypeCard(text: type),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        title,
                        style: GoogleFonts.heebo(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Ch.$chapter',
                          style: GoogleFonts.heebo(
                            fontSize: 13,
                            height: 1.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        rating != null
                            ? Container(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 18,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      rating,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textSelectionHandleColor
                                            .withOpacity(.6),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.0),
        ],
      ),
    );
  }
}

class RecentList extends StatelessWidget {
  const RecentList({
    Key key,
    @required this.width,
    this.data,
  }) : super(key: key);

  final double width;
  final List<Map> data;

  @override
  Widget build(BuildContext context) {
    List<Map> data = this.data.length >= 10
        ? this.data.reversed.toList().sublist(0, 10)
        : this.data;
    return Container(
      width: width,
      height: width * .63,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: data
            .asMap()
            .map(
              (i, e) {
                return MapEntry(
                  i,
                  Container(
                    margin: EdgeInsets.only(
                      right: i == 0 ? 0.0 : i == data.length - 1 ? 5.0 : 0.0,
                      left: i == 0 ? 5.0 : 0.0,
                    ),
                    child: SingleSlider(
                      width: width,
                      image: e['image'],
                      title: e['title'],
                      chapterNum: e['chapterName'],
                      mangaId: e['mangaId'],
                      chapterId: e['chapterId'],
                    ),
                  ),
                );
              },
            )
            .values
            .toList(),
      ),
    );
  }
}

class SingleSlider extends StatelessWidget {
  const SingleSlider({
    Key key,
    @required this.width,
    this.chapterNum,
    this.image,
    this.title,
    this.mangaId,
    this.chapterId,
  }) : super(key: key);

  final double width;
  final String image, title, chapterNum, mangaId, chapterId;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Modular.to.pushNamed('readmanga', arguments: {
        "mangaId": mangaId,
        "currentId": chapterId,
      }),
      child: Container(
        margin: EdgeInsets.only(left: 5.0, right: 5.0),
        width: width * .32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              width: width * .32,
              height: width * .43,
              useOldImageOnUrlChange: true,
              placeholder: (_, __) => ImageShimmerPlaceHolder(
                width: width * .32,
                height: width * .43,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                title,
                style: GoogleFonts.heebo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Ch. $chapterNum',
              style: GoogleFonts.heebo(
                fontSize: 13,
                height: 1.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
