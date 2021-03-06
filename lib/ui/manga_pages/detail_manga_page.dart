import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:komikcast/bloc/blur_bloc.dart';
import 'package:komikcast/bloc/favorite_bloc.dart';
import 'package:komikcast/bloc/scroll_bloc.dart';
import 'package:komikcast/bloc/sliver_bloc.dart';
import 'package:komikcast/data/comic_data.dart';
import 'package:komikcast/data/favorite_data.dart';
import 'package:komikcast/models/detail_comic.dart';
import 'package:komikcast/ui/manga_pages/tab_chapters.dart';
import 'package:komikcast/ui/manga_pages/tab_overview.dart';

// ignore: slash_for_doc_comments
/**
 * PARAMETER
 * - image  ex: https://komikcast.com/wp-content/uploads/2018/06/00a-e1529951476666.jpg
 * - title  ex: Chuuko demo Koi ga Shitai!
 * - linkId ex: chuuko-demo-koi-ga-shitai/
 */

class DetailManga extends StatefulWidget {
  DetailManga({this.image, this.title, this.linkId});

  final String image, title, linkId;

  @override
  _DetailMangaState createState() => _DetailMangaState();
}

class _DetailMangaState extends State<DetailManga> {
  var top = 0.0;
  var blur = 0.0;
  bool isLoaded = false;
  DetailComic detail = DetailComic();
  SingleChapterDetail idFirstChapter;

  @override
  void initState() {
    super.initState();
    getData();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  void getData() async {
    detail = await ComicData.getDetailKomik(id: widget.linkId);
    idFirstChapter = detail.listChapters.last;
    if (this.mounted)
      setState(() {
        isLoaded = true;
      });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // ignore: close_sinks
    final sliverBloc = Modular.get<SliverBloc>();
    // ignore: close_sinks
    final blurBloc = Modular.get<BlurBloc>();

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Container(
          width: width,
          height: height,
          child: Stack(
            children: [
              CustomScrollView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: width,
                    backgroundColor: Theme.of(context).textSelectionColor,
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        top = constraints.biggest.height;
                        blur = ((width / constraints.biggest.height) - 1) * 4;
                        // BLOC DISPATCH
                        blurBloc.add(blur);
                        sliverBloc.add(
                          top ==
                                  MediaQuery.of(context).padding.top +
                                      kToolbarHeight
                              ? true
                              : false,
                        );
                        return FlexibleSpaceBar(
                          title: Container(),
                          background: PageHeader(
                            image: widget.image,
                            title: widget.title,
                            isLoaded: isLoaded,
                            width: width,
                            detail: detail,
                          ),
                        );
                      },
                    ),
                    leading: Container(),
                    actions: [Container()],
                  ),
                  SliverContent(
                      width: width,
                      setState: this.setState,
                      isLoaded: isLoaded,
                      detail: detail,
                      mangaId: widget.linkId),
                ],
              ),
              CustomAppBar(
                sliverBloc: sliverBloc,
                width: width,
                image: widget.image,
                title: widget.title,
                isLoaded: isLoaded,
                detail: detail,
              ),
              isLoaded
                  ? FloatingMenu(
                      width: width,
                      mangaId: widget.linkId,
                      chapter: detail.listChapters.last,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class FloatingMenu extends StatelessWidget {
  const FloatingMenu({
    Key key,
    @required this.width,
    this.chapter,
    this.mangaId,
  }) : super(key: key);

  final double width;
  final SingleChapterDetail chapter;
  final String mangaId;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: width,
        height: kToolbarHeight,
        padding: EdgeInsets.only(right: 10.0, left: 2.0),
        decoration: BoxDecoration(
          color: Theme.of(context).textSelectionColor.withOpacity(0),
          // border: Border(
          //   top: BorderSide(
          //     color: Theme.of(context).brightness == Brightness.light
          //         ? Theme.of(context).textSelectionHandleColor.withOpacity(.2)
          //         : Colors.grey[700],
          //   ),
          // ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(kToolbarHeight),
            //   child: Material(
            //     borderRadius: BorderRadius.circular(kToolbarHeight),
            //     color: Colors.transparent,
            //     child: InkWell(
            //       onTap: () {},
            //       child: Container(
            //         width: kToolbarHeight,
            //         height: kToolbarHeight,
            //         color: Colors.transparent,
            //         alignment: Alignment.center,
            //         child: FaIcon(
            //           FontAwesomeIcons.commentAlt,
            //           color: Theme.of(context)
            //               .textSelectionHandleColor
            //               .withOpacity(.5),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(width: 5),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(width),
                  child: Material(
                    borderRadius: BorderRadius.circular(width),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(width),
                      ),
                      child: InkWell(
                        onTap: () => Modular.to.pushNamed(
                          '/readmanga',
                          arguments: {
                            'mangaId': mangaId,
                            'currentId': chapter.linkId,
                          },
                        ),
                        child: Container(
                          height: kToolbarHeight - 10,
                          alignment: Alignment.center,
                          child: Text(
                            'Baca Chapter Pertama',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    Key key,
    @required this.sliverBloc,
    @required this.width,
    this.image,
    this.title,
    this.isLoaded,
    this.detail,
  }) : super(key: key);

  final SliverBloc sliverBloc;
  final double width;
  final String image, title;
  final bool isLoaded;
  final DetailComic detail;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      child: BlocBuilder<SliverBloc, bool>(
        builder: (context, state) => Container(
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      BlocBuilder<SliverBloc, bool>(
                        bloc: sliverBloc,
                        builder: (context, state) => IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).brightness ==
                                        Brightness.dark &&
                                    state == true
                                ? Colors.white
                                : Theme.of(context).brightness ==
                                            Brightness.dark &&
                                        state == false
                                    ? Colors.white
                                    : Theme.of(context).brightness ==
                                                Brightness.light &&
                                            state == true
                                        ? Colors.black
                                        : Colors.white,
                          ),
                          onPressed: () => Modular.to.pop(),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      state
                          ? Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.headline6,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                BlocBuilder<SliverBloc, bool>(
                  builder: (context, state) => IconButton(
                    icon: Icon(
                      Icons.cloud_download,
                      color: Theme.of(context).brightness == Brightness.dark &&
                              state == true
                          ? Colors.white.withOpacity(isLoaded ? 1 : .4)
                          : Theme.of(context).brightness == Brightness.dark &&
                                  state == false
                              ? Colors.white.withOpacity(isLoaded ? 1 : .4)
                              : Theme.of(context).brightness ==
                                          Brightness.light &&
                                      state == true
                                  ? Colors.black.withOpacity(isLoaded ? 1 : .4)
                                  : Colors.white.withOpacity(isLoaded ? 1 : .4),
                    ),
                    onPressed: () {
                      if (isLoaded)
                        Modular.to.pushNamed(
                          '/downloadmanga',
                          arguments: {
                            "detail": detail,
                          },
                        );
                    },
                  ),
                ),
              ],
            ),
          ),
          width: width,
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 8.0,
          ),
          decoration: BoxDecoration(
            color: state
                ? Theme.of(context).textSelectionColor
                : Colors.transparent,
            boxShadow: [
              BoxShadow(
                color: state ? Colors.grey : Colors.transparent,
                offset: Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliverContent extends StatelessWidget {
  const SliverContent({
    Key key,
    @required this.width,
    this.setState,
    this.isLoaded,
    this.detail,
    this.mangaId,
  }) : super(key: key);

  final Function setState;
  final bool isLoaded;
  final double width;
  final DetailComic detail;
  final String mangaId;

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: TabContainer(
        width: width,
        setState: setState,
        isLoaded: isLoaded,
        detail: detail,
        mangaId: mangaId,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => isLoaded
              ? ContentManga(
                  width: width,
                  detail: detail,
                  mangaId: mangaId,
                )
              : Container(
                  width: width,
                  height: kToolbarHeight * 4,
                  child: Center(child: CircularProgressIndicator()),
                ),
          childCount: 1,
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    Key key,
    @required this.width,
    @required this.title,
    @required this.image,
    this.isLoaded,
    this.detail,
  }) : super(key: key);

  final double width;
  final String image, title;
  final bool isLoaded;
  final DetailComic detail;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  image,
                ),
              ),
            ),
            child: BlocBuilder<BlurBloc, double>(
              builder: (context, state) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: state, sigmaY: state),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(.4),
          ),
        ),
        Positioned(
          bottom: 20.0,
          left: 20.0,
          right: 20.0,
          child: Container(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                isLoaded ? StatusManga(text: detail.status) : Container(),
                TitleManga(text: title),
                AuthorManga(text: isLoaded ? detail.author : '-'),
                isLoaded ? RatingManga(value: detail.rating) : Container(),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class ContentManga extends StatefulWidget {
  ContentManga({
    Key key,
    @required this.width,
    this.detail,
    this.mangaId,
  }) : super(key: key);

  final double width;
  final DetailComic detail;
  final String mangaId;

  @override
  _ContentMangaState createState() => _ContentMangaState();
}

class _ContentMangaState extends State<ContentManga> {
  var index = 0;

  var widgetList = [];

  @override
  void initState() {
    super.initState();
    widgetList = [
      TabOverview(detail: widget.detail),
      TabChapters(
        detail: widget.detail,
        mangaId: widget.mangaId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, state) {
        index = DefaultTabController.of(context).index;
        Modular.get<ScrollBloc>()
            .add(state.biggest.height >= MediaQuery.of(context).size.height);
        return Column(
          children: [
            widgetList[index],
            SizedBox(height: kToolbarHeight),
          ],
        );
      },
    );
  }
}

class TabContainer extends StatelessWidget {
  const TabContainer({
    Key key,
    @required this.width,
    this.setState,
    this.isLoaded,
    this.detail,
    this.mangaId,
  }) : super(key: key);

  final double width;
  final Function setState;
  final bool isLoaded;
  final DetailComic detail;
  final String mangaId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 56.0,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).textSelectionHandleColor.withOpacity(.2),
          ),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).primaryColor
            : Colors.grey[100],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TabBar(
            onTap: (state) {
              setState(() {});
            },
            isScrollable: true,
            indicatorColor: Theme.of(context).textSelectionHandleColor,
            labelPadding: EdgeInsets.only(
              bottom: 10,
              left: 20,
              right: 20,
              top: 10,
            ),
            tabs: [
              Tab(
                child: Text(
                  'Overview',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textSelectionHandleColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Chapters',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textSelectionHandleColor,
                  ),
                ),
              ),
            ],
          ),
          isLoaded
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(width),
                    child: Material(
                      child: BlocBuilder<FavoriteBloc, List<Map>>(
                        builder: (context, state) {
                          var isFavorited = state
                                  .where(
                                    (element) =>
                                        element['mangaId'] ==
                                        (mangaId.substring(
                                                    mangaId.length - 1) ==
                                                '/'
                                            ? mangaId.replaceAll('/', '')
                                            : mangaId),
                                  )
                                  .toList()
                                  .length >
                              0;

                          return IconButton(
                            icon: Icon(
                              isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorited
                                  ? Colors.red
                                  : Theme.of(context)
                                      .textSelectionHandleColor
                                      .withOpacity(.8),
                            ),
                            onPressed: () async {
                              isFavorited
                                  ? await FavoriteData.unsaveFavorite(
                                      mangaId: mangaId,
                                    )
                                  : await FavoriteData.saveFavorite(
                                      mangaId: mangaId,
                                      currentId:
                                          detail.listChapters.first.linkId,
                                      detailChapter:
                                          detail.listChapters.first.chapter,
                                      image: detail.image,
                                      title: detail.title,
                                      type: detail.type,
                                      context: context,
                                    );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

class RatingManga extends StatelessWidget {
  const RatingManga({
    Key key,
    this.value,
  }) : super(key: key);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 6.0),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: Colors.yellow,
            size: 15,
          ),
          SizedBox(width: 4.0),
          Text(
            value,
            style: GoogleFonts.heebo(
              fontSize: 13.0,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class AuthorManga extends StatelessWidget {
  const AuthorManga({
    Key key,
    this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      'By $text',
      style: GoogleFonts.heebo(
        fontSize: 14.0,
        color: Colors.white60,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class TitleManga extends StatelessWidget {
  const TitleManga({
    Key key,
    this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.heebo(
        fontSize: 24.0,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class StatusManga extends StatelessWidget {
  const StatusManga({
    Key key,
    this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: text.toLowerCase() != 'ongoing' ? Colors.red : Colors.blue,
        borderRadius: BorderRadius.circular(5.6),
      ),
      child: Text(
        text,
        style: GoogleFonts.heebo(fontSize: 13.0, color: Colors.white),
      ),
    );
  }
}
