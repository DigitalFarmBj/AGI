
import 'package:flutter/material.dart';

import 'Constants/Constants.dart';
import 'Models/CDM.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  bool isExpanded = false;
  int selectedIndex = -1;
  static List<CDM> cdms = [
    //
    CDM(Icons.grid_view, 'Dashboard', []),
    CDM(Icons.grid_view, 'Catégories', []),
    CDM(Icons.grid_view, 'Posts', []),
    CDM(Icons.grid_view, 'Analitics', []),
    CDM(Icons.grid_view, 'Posts', []),
  ];
  Widget ligne() {
    return Row(
      children: [
        isExpanded ? blackIconTiles() : blackIconMenu(),
        invisibleSubMenus(),
      ],
    );
  }

  Widget blackIconTiles() {
    return Container(
      width: 200,
      color: Colorz.complexDrawerBlack,
      child: Column(children: [
        // controlTile(),
        Expanded(
            child: ListView.builder(
          itemCount: cdms.length,
          itemBuilder: (context, index) {
            CDM cdm = cdms[index];
            bool selected = selectedIndex == index;
            return ExpansionTile(
                onExpansionChanged: (z) {
                  setState(() {
                    selectedIndex = z ? index : -1;
                  });
                },
                leading: Icon(
                  cdm.icon,
                  color: Colors.white,
                ),
                title: const Text(""));
          },
        ))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
   // double width = MediaQuery.of(context).size.width;
    return Container(
      //width: width / 2,
      child: ligne(),
    );
  }

  Widget blackIconMenu() {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: 100,
      color: Colorz.complexDrawerBlack,
      child: Column(
        children: [
          controlButton(),
          Expanded(
            child: ListView.builder(
                itemCount: cdms.length,
                itemBuilder: (contex, index) {
                  // if(index==0) return controlButton();
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Icon(cdms[index].icon, color: Colors.white),
                    ),
                  );
                }),
          ),
          // accountButton(),
        ],
      ),
    );
  }

  /* Widget controlButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 30),
      child: InkWell(
        onTap: (){},
        child: Container(
          height: 45,
          alignment: Alignment.center,
          child: FlutterLogo(
            size: 40,
          ),
        ),
      ),
    );
  }*/
  Widget controlButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: InkWell(
        onTap: expandOrShrinkDrawer,
        child: Container(
          height: 45,
          alignment: Alignment.center,
          child: const FlutterLogo(
            size: 40,
          ),
        ),
      ),
    );
  }

  /* Widget blackIconMenu() {
    return Container(
      width: 100,
      color: Colorz.complexDrawerBlack,
      child: ListView.builder(
        itemCount: cdms.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              height: 45,
              alignment: Alignment.center,
              child: Icon(
                cdms[index].icon,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
*/
  Widget invisibleSubMenus() {
    // List<CDM> _cmds = cdms..removeAt(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isExpanded ? 0 : 125,
      color: Colorz.compexDrawerCanvasColor,
      child: Column(
        children: [
          Container(height: 95),
          Expanded(
            child: ListView.builder(
                itemCount: cdms.length,
                itemBuilder: (context, index) {
                  CDM cmd = cdms[index];
                  // if(index==0) return Container(height:95);
                  //controll button has 45 h + 20 top + 30 bottom = 95

                  bool selected = selectedIndex == index;
                  bool isValidSubMenu = selected && cmd.submenus.isNotEmpty;
                  return subMenuWidget(
                      [cmd.title]..addAll(cmd.submenus), isValidSubMenu);
                }),
          ),
        ],
      ),
    );
  }

  /* Widget invisibleSubMenus() {
    return Container(
      width: 125,
      color: Colorz.compexDrawerCanvasColor,
      child: ListView.builder(
        itemCount: cdms.length,
        itemBuilder: (context, index) {
          bool selected = selectedIndex == index;
          CDM cdm = cdms[index];
          bool isValidSubMenu = selected && cdm.submenus.isNotEmpty;

          return subMenuWidget( [cdm.title]..addAll(cdm.submenus), selected);
        },
      ),
    );
  }
*/
  Widget subMenuWidget(List<String> submenus, bool isValidSubMenu) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: isValidSubMenu ? submenus.length.toDouble() * 37.5 : 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: isValidSubMenu
              ? Colorz.complexDrawerBlueGrey
              : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )),
      child: ListView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: isValidSubMenu ? submenus.length : 0,
          itemBuilder: (context, index) {
            String subMenu = submenus[index];
            return sMenuButton(subMenu, index == 0);
          }),
    );
  }

/*  Widget subMenuWidget(
    
    List<String> submenus,
    bool isValideSubmenu,
  ) 
  {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      alignment: Alignment.center,
      color: Colorz.complexDrawerBlueGrey,
      height: isValideSubmenu?200:45,
      decoration: BoxDecoration(
        
          color:isValideSubmenu? Colorz.complexDrawerBlueGrey:Colors.transparent,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          )),
      child: ListView.builder(
          padding: EdgeInsets.all(6),
          itemCount: isValideSubmenu?submenus.length:0,
          itemBuilder: (context, index) {
            String submenu = submenus[index];
            return InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                //alignment: Alignment.center,
                child: Txt(
                  text: submenu,
                  fontSize: index==0?17:14,
                  color: index==0? Colors.white:Colors.grey,
                  fontWeight:  FontWeight.bold,
                ),
              ),
            );
          },
        ),
    );
  }
*/
  Widget invisibleSubMenuWidget() {
    return Container();
  }

  void expandOrShrinkDrawer() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  Widget sMenuButton(String subMenu, bool bool) {
    return Container();
  }

  /* List<IconData> icons = [
    Icons.grid_view,
    Icons.subscriptions,
    Icons.markunread_mailbox,
    Icons.pie_chart,
    Icons.power,
    Icons.explore,
    Icons.settings
  ];*/
}
