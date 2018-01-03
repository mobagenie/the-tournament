<share>
  <div class="">
    <h5 class="ui small header">公開URL</h5>
    <div class="ui small info message">
      <a href="https://tournament-7e3b7.firebaseapp.com/tournaments/{ parent.opts.id }" target="_blank">
        https://tournament-7e3b7.firebaseapp.com/tournaments/{ parent.opts.id }
      </a>
      <i class="icon external small"></i>
    </div>

    <h5 class="ui small header">
      埋め込みタグ
    </h5>
    <div class="ui fluid input">
      <input type="text" readonly="readonly" value="{ embedCode }">
    </div>

    <h5 class="ui small header">
      画像ダウンロード
      <div class="ui mini label">
        開発中..😢
      </div>
    </h5>
    <div class="ui icon basic disabled button">
      <i class="icon download"></i>
      画像をダウンロードする
    </div>

    <!--
    <h5 class="ui small header">SNSシェア</h5>
    <div class="ui horizontal list">
      <div class="item">
        <iframe src="https://www.facebook.com/plugins/share_button.php?href=https%3A%2F%2Fdevelopers.facebook.com%2Fdocs%2Fplugins%2F&layout=button&size=small&mobile_iframe=true&appId=139414576217599&width=61&height=20" width="61" height="20" style="border:none;overflow:hidden" scrolling="no" frameborder="0" allowTransparency="true"></iframe>
      </div>
      <div class="item">
        <iframe
          src="https://platform.twitter.com/widgets/tweet_button.html?size=s&url=https%3A%2F%2Fdev.twitter.com%2Fweb%2Ftweet-button&via=twitterdev&related=twitterapi%2Ctwitter&text=custom%20share%20text&hashtags=example%2Cdemo"
          width="70"
          height="20"
          title="Twitter Tweet Button"
          style="border: 0; overflow: hidden;">
        </iframe>
      </div>
    </div>
    -->
  </div>


  <style>
    .ui.small.info.message a { word-break: break-all; }
  </style>


  <script>
    var that = this
    that.tournament = that.parent.tournament
    that.id = that.parent.opts.id
    that.embedHeight = 1000 //TODO

    that.embedCode = "<div style='position:relative!important;width:100%!important;max-width:100%!important;margin-bottom:20px!important;overflow:auto !important;-webkit-overflow-scrolling:touch !important;'><iframe src='https://app.the-tournament.jp/alpha/" + that.id + ".html?utm_campaign=embed&utm_medium="+ that.tournament.userId +"&utm_source="+ that.id +"' seamless frameborder='0' scrolling='no' width='100%' height='"+ that.embedHeight +"' style='width:1px;min-width:100%;'></iframe></div>"
  </script>
</share>
