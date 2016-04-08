# AutoRefresh

* An easy sample code to use auto pull-up-refresh

* use the  property "refreshDistance" to set the auto-refresh position from bottom

* Example

  _footer = [[AXLFooterAutoRefreshView alloc]init];
  [_footer setFooterAutoRefreshWithScrollView:tableView andCallBack:^{

     //TODO

  }];
  
  