# -*- coding: utf-8 -*-
class AccountViewController < UIViewController
  def viewDidLoad
    super

    ApplicationUser.sharedUser.addObserver(self, forKeyPath:'hatena_id', options:0, context:nil)
    @user = ApplicationUser.sharedUser.to_bookmark_user
    self.navigationItem.title = @user.name
    self.navigationItem.backBarButtonItem = UIBarButtonItem.titled("戻る")

    ## 背景
    view << UITableView.alloc.initWithFrame(view.bounds, style:UITableViewStyleGrouped)

    @dataSource = [
      {
        :title => "設定",
        :rows => [
          {
            :label  => "はてなアカウント",
            :color  => '#385487'.uicolor,
            :action => 'open_hatena_config'
          }
        ]
      },
    ]

    @imageView = UIImageView.new.tap do |v|
      v.frame = [[10, 10], [48, 48]]
      v.layer.tap do |l|
        l.masksToBounds = true
        l.cornerRadius  = 5.0
      end
      v.setImageWithURL(@user.profile_image_url.nsurl, placeholderImage:nil)
      view << v
    end

    @nameLabel = UILabel.new.tap do |v|
      v.frame = [[68, 10], [200, 48]]
      v.font  = UIFont.boldSystemFontOfSize(18)
      v.text  = @user.name
      v.shadowColor = UIColor.whiteColor
      v.shadowOffset = [0, 1]
      v.backgroundColor = UIColor.clearColor
      view << v
    end

    @menuTable = UITableView.alloc.initWithFrame([[0, 59], self.view.bounds.size], style:UITableViewStyleGrouped).tap do |v|
      v.dataSource = v.delegate = self
      view << v
    end
  end

  def viewWillAppear(animated)
    super
    self.navigationController.setToolbarHidden(true, animated:animated)

    ## JASlidePanels の初期化タイミングでボタンスタイルが当たらないので明示的にセット
    if self.navigationItem.leftBarButtonItem
      self.navigationItem.leftBarButtonItem.styleClass = 'navigation-button'
    end
    @menuTable.deselectRowAtIndexPath(@menuTable.indexPathForSelectedRow, animated:animated)
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    id = "basis-cell"
    rowData = @dataSource[indexPath.section][:rows][indexPath.row]

    cell = tableView.dequeueReusableCellWithIdentifier(id) || UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier:id)
    cell.textLabel.text = rowData[:label]
    if rowData[:detail]
      cell.detailTextLabel.text = rowData[:detail]
    end

    if (color = rowData[:color])
      cell.textLabel.textColor = color
    end

    if (accessory = rowData[:accessoryType])
      cell.accessoryType = accessory
    end

    cell
  end

  def tableView(tableView, titleForHeaderInSection:section)
    if (title = @dataSource[section][:title])
      return title
    end
  end

  def tableView(tableView, numberOfRowsInSection:section)
    @dataSource[section][:rows].size
  end

  def numberOfSectionsInTableView (tableView)
    @dataSource.size
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    if (action = @dataSource[indexPath.section][:rows][indexPath.row][:action])
      self.send(action)
    end
  end

  def observeValueForKeyPath(keyPath, ofObject:object, change:change, context:context)
    @user = ApplicationUser.sharedUser.to_bookmark_user

    ## view 更新
    navigationItem.title = @user.name
    @imageView.setImageWithURL(@user.profile_image_url.nsurl, placeholderImage:nil)
    @nameLabel.text = @user.name
  end

  def open_hatena_config
    self.presentModalViewController(
      UINavigationController.alloc.initWithRootViewController(
        AccountConfigViewController.new.tap { |c| c.allow_cancellation = true }
      ),
      animated:true
    )
  end

  def open_website
    bookmark = Bookmark.new({
      :title => 'HBFav2',
      :link  => 'http://hbfav.bloghackers.net/',
      :count => nil
    })
    controller = WebViewController.new
    controller.bookmark = bookmark
    self.navigationController.pushViewController(controller, animated:true)
  end

  def open_review
    "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=477950722&pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8".nsurl.open
  end

  def open_report
    "https://github.com/naoya/HBFav2/issues?state=open".nsurl.open
  end

  def dealloc
    NSLog("dealloc: " + self.class.name)
    ApplicationUser.sharedUser.removeObserver(self, forKeyPath:'hatena_id')
    super
  end
end
