<edit>
  <div class="ui stackable centered padded grid" if={ tournament }>
    <div class="ui one wide dark column" data-is="menu"></div>

    <div class="ui five wide secondary column" if={ selectedTab }>
      <div class="ui basic tab segment { active: tabSelected('settings') }">
        <settings tournament={ tournament }></settings>
      </div>
      <div class="ui basic tab segment { active: tabSelected('teams') }">
        <teams tournament={ tournament }></teams>
      </div>
      <div class="ui basic tab segment { active: tabSelected('results') }">
        <h3 class="ui tiny header">試合結果の登録</h3>
        <results tournament={ tournament } editable={ true }></results>
      </div>
      <div class="ui basic tab segment { active: tabSelected('share') }">
        <share tournament={ tournament }></share>
      </div>
    </div>

    <div class="ui { ten: selectedTab, fifteen: !selectedTab } wide bracket column">
      <div class="ui basic segment">
        <bracket-header tournament={ tournament }></bracket-header>
        <div class="ui hidden divider"></div>
        <bracket name="bracket" tournament={ tournament } editable={ true }></bracket>
        <br><br>

        <div class="ui stackable centered secondary segment grid" if={ user.isAnonymous }>
          <div class="ui sixteen wide column">
            <h6 class="ui tiny dividing header">
              <i class="icon question circle"></i>
              使い方ガイド
            </h6>
          </div>
          <div class="ui eight wide column">
            <small class="ui tiny header">10秒動画で使い方をチェック</small>
            <video muted controls poster="/img/howto/cover.png">
              <source src="/img/howto/howto.mp4" type="video/mp4" />
            </video>
          </div>
          <div class="ui eight wide column">
            <small class="ui tiny header">その他のドキュメント</small>
            <div class="ui link list">
              <a class="item" href="https://tayori.com/faq/8ffbdba0a70dcacc24ed64550dfa39a4332ac44b/detail/db5e2bf5b8fde4b521b36837ce95fc003ba97318" target="_blank">
                <i class="icon caret right"></i>
                参加者を改行テキストで入力したい
              </a>
              <a class="item" href="https://tayori.com/faq/8ffbdba0a70dcacc24ed64550dfa39a4332ac44b/detail/edd19af7c7b2442d3d7339acc35ca8d29f54c8ae" target="_blank">
                <i class="icon caret right"></i>
                組み合わせをシャッフルしたい
              </a>
              <a class="item" href="https://tayori.com/faq/8ffbdba0a70dcacc24ed64550dfa39a4332ac44b/detail/c86db5c03b7e59da3a9a738a0422926e2ea158aa" target="_blank">
                <i class="icon caret right"></i>
                試合の詳細情報を登録したい
              </a>
              <a class="item" href="https://tayori.com/faq/8ffbdba0a70dcacc24ed64550dfa39a4332ac44b/detail/ed7e8086db9cb6370eb66906b78d3373f02c7a08" target="_blank">
                <i class="icon caret right"></i>
                シードの選手を設定したい
              </a>
              <a class="item" href="https://tayori.com/faq/8ffbdba0a70dcacc24ed64550dfa39a4332ac44b" target="_blank">
                ...もっとドキュメントを見る
              </a>
            </div>
          </div>
        </div>
      </div>
      <br><br>
    </div>
  </div>

  <div class="ui bottom fixed borderless menu" if={ tournament }>
    <div class="item">
      <button data-tnmt-creation={ notSavedYet } class="ui red small button" onclick={ saveTournament }>保存する</button>
    </div>

    <div class="right menu">
      <div class="link item" onclick={ close }>
        <i class="icon remove"></i>
        閉じる
      </div>
    </div>
  </div>


  <style>
    /* メニューまわり */
    .ui.secondary.column, .ui.secondary.grid { background-color: #F3F4F5 !important; }
    .ui.one.wide.column {
      padding: 0 !important;
      z-index: 2;
    }
    .ui.dark.column { background-color: #2D3E4F !important; }
    .ui.bracket.column { min-height: calc(100vh - 45px) }
    .ui.menu.fixed { z-index: 2147483646 !important; }

    /* タブ切り替えアニメーション */
    @media screen and (min-width: 481px) {
      @keyframes fade-in {
        0% {
          display: none;
          transform: translate(-100px, 0);
          opacity: 0;
        }
        1% {
          display: block;
          transform: translate(-100px, 0);
          opacity: 0;
        }
        100% {
          display: block;
          transform: translate(0, 0);
          opacity: 1;
        }
      }
      .ui.five.wide.column {
        animation-duration: 300ms;
        animation-name: fade-in;
      }
    }

    /*  PCではカラム別にスクロール */
    @media screen and (min-width: 481px) {
      .five.wide.column, .ten.wide.column {
        height: 100vh !important;
        margin-bottom: 30px !important;
        overflow: scroll !important;
      }
    }
    /*  スマホでは編集カラムをデフォルト非表示 */
    @media screen and (max-width: 480px) {
      .five.wide.secondary.column {
         padding: 0 !important;
       }
    }

    video { max-width: 100%; }

    /* FIXME: なぜかfocus時にafter要素がここに追加されてしまう問題対応 */
    .ui.wide.bracket.column:after { display: none !important; }
  </style>


  <script>
    /***********************************************
    * Settings
    ***********************************************/
    var that = this
    that.tournament = null
    that.tournamentChanged = false
    that.isMobile = window.innerWidth <= 480
    that.selectedTab = (that.isMobile) ? null : 'settings'
    that.notSavedYet = false

    /* metatag setting */
    let meta = {
      title: 'トーナメント表の編集',
      noindex: true
    }
    that.setMetatags(meta)


    /***********************************************
    * Observables
    ***********************************************/
    var authUnsubscribe = firebase.auth().onAuthStateChanged(function(user) {
      that.user = user
    })

    // unmount処理
    that.on('unmount', function() {
      authUnsubscribe()
      obs.trigger("footerVisibility", true)
      obs.off('menuTabChanged')
      obs.off('tournamentChanged')
      obs.off('showByeChanged')
    })

    obs.on("menuTabChanged", function(tab) {
      that.selectedTab = tab
      that.update()
    })

    // Footer表示制御
    obs.trigger("footerVisibility", false)

    obs.on("tournamentChanged", function(tournament) {
      that.tournament = tournament
      that.tournamentChanged = true
      that.update()
    })

    obs.on("showByeChanged", function(showBye){
      that.tags.bracket.showBye = showBye
      that.tags.bracket.update()
    })

    obs.trigger("dimmerChanged", 'active')
    var docRef = db.collection("tournaments").doc(opts.id)
    docRef.get().then(function(doc){
      if(doc.exists) {
        that.tournament = doc.data()

        /* 権限確認 */
        if(that.tournament.userId != that.user.uid && that.user.uid != '14') {
          obs.trigger("dimmerChanged", '')
          obs.trigger("flashChanged", {type:'error',text:'トーナメント表の編集権限がありません…。ログイン状態を確認してください。'})
          route('/')
          return false
        }
      }else {
        that.tournament = {
          title: "",
          detail: null,
          consolationRound: false,
          teams: [{"name":"Player1"},{"name":"Player2"},{"name":"Player3"},{"name":"Player4"},{"name":"Player5"},{"name":"Player6"},{"name":"Player7"},{"name":"Player8"}],
          results: {
            0: [ {"score":{0:null,1:null},"comment":null,"winner":null}, {"score":{0:null,1:null},"comment":null,"winner":null}, {"score":{0:null,1:null},"comment":null,"winner":null}, {"score":{0:null,1:null},"comment":null,"winner":null} ],
            1: [ {"score":{0:null,1:null},"comment":null,"winner":null}, {"score":{0:null,1:null},"comment":null,"winner":null} ],
            2: [ {"score":{0:null,1:null},"comment":null,"winner":null}, {"score":{0:null,1:null},"comment":null,"winner":null} ]
          },
          nameWidth: 100,
          scoreWidth: 40,
          createdAt: new Date(),
          updatedAt: new Date(),
          userId: that.user.uid
        }
        that.notSavedYet = true
      }
      that.update()
      obs.trigger("dimmerChanged", '')
    })


    /***********************************************
    * Functions
    ***********************************************/
    close() {
      if(that.tournamentChanged) {
        let alertMessage = '編集画面を閉じると、保存されていない変更が破棄されます。本当によろしいですか？'
        if(!confirm(alertMessage)) { return false }
      }
      route('/tournaments/'+ opts.id)
    }

    saveTournament() {
      obs.trigger("dimmerChanged", 'active')

      if(that.tournament.title=='') {
        obs.trigger("dimmerChanged", '')
        alert('トーナメント名を入力してください！')
        return false
      }

      /* 保存処理 */
      that.tournament.updatedAt = new Date()
      var docRef = db.collection("tournaments").doc(opts.id)
      docRef.set(that.tournament)
      .then(function() {
        that.tournamentChanged = false
        that.notSavedYet = false
        obs.trigger("flashChanged", {type:'success',text:'トーナメント表を保存しました！'})


        /* 匿名ユーザーはDBにフラグ立てとく */
        if(that.user.isAnonymous) {
          let tmpRef = db.collection("anonymousUsers").doc(that.user.uid)
          tmpRef.set({ updatedAt: new Date() })
        }
      })
      .catch(function(error) {
        obs.trigger("flashChanged", {type:'error',text:'トーナメント表の保存に失敗しました…(´；ω；｀)'})
      })
      .then(function(){
        obs.trigger("dimmerChanged", '')
        that.update()
      })
    }

    tabSelected(tab) {
      return tab == that.selectedTab
    }

    removeTournament(e) {
      var ok = confirm('データを削除します。本当によろしいですか？')
      if(!ok) { return false }

      obs.trigger("dimmerChanged", 'active')
      db.collection("tournaments").doc(opts.id).delete().then(function() {
        obs.trigger("dimmerChanged", '')
        route('/mypage')
      })
    }
  </script>
</edit>
