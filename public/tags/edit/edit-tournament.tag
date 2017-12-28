<edit-tournament>
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

    <div class="ui { ten: selectedTab, fifteen: !selectedTab } wide column">
      <div class="ui basic segment">
        <bracket tournament={ tournament } editable={ true }></bracket>
        <match-modal tournament={ tournament }></match-modal>
        <team-modal tournament={ tournament }></team-modal>
      </div>
      <br><br>
    </div>
  </div>

  <div class="ui bottom fixed borderless menu">
    <div class="item">
      <button class="ui red small button" onclick={ saveTournament } disabled={ JSON.stringify(tournament) == JSON.stringify(originalTournament) }>保存する</button>
    </div>

    <div class="right menu">
      <a href="/tournaments/{ opts.id }" class="item">
        <i class="icon remove"></i>
        閉じる
      </a>
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
    .ui.ten.wide.column { min-height: calc(100vh - 45px) }
    .ui.menu.fixed { z-index: 999; }

    /* タブ切り替えアニメーション */
    @media screen and (max-width: 480px) {
      @keyframes fade-in {
        0% {
          display: none;
          transform: translate(0, -100px);
          opacity: 0;
        }
        1% {
          display: block;
          transform: translate(0, -100px);
          opacity: 0;
        }
        100% {
          display: block;
          transform: translate(0, 0);
          opacity: 1;
        }
      }
    }
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
    }
    .ui.five.wide.column {
      animation-duration: 300ms;
      animation-name: fade-in;
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
  </style>


  <script>
    /***********************************************
    * Variables
    ***********************************************/
    var that = this
    that.isMobile = window.innerWidth <= 480
    that.selectedTab = (that.isMobile) ? null : 'settings'


    /***********************************************
    * Observables
    ***********************************************/
    firebase.auth().onAuthStateChanged(function(user) {
      that.user = user
    })

    obs.on("menuTabChanged", function(tab) {
      that.selectedTab = tab
      that.update()
    })

    // Footer表示制御
    obs.trigger("footerVisibility", false)
    that.on('unmount', function() {
      obs.trigger("footerVisibility", true)
    })

    obs.on("tournamentChanged", function(tournament) {
      that.tournament = tournament
      that.update()
    })

    obs.trigger("dimmerChanged", 'active')
    var docRef = db.collection("tournaments").doc(opts.id)
    docRef.get().then(function(doc){
      if(doc.exists) {
        that.tournament = doc.data()
        that.originalTournament = doc.data()
        that.update()
        obs.trigger("dimmerChanged", '')
      }else {
        alert('ごめんなさい、トーナメント表の取得に失敗しました…。URLを再度ご確認ください。')
        obs.trigger("dimmerChanged", '')
        route('/')
      }
    })


    /***********************************************
    * Functions
    ***********************************************/
    saveTournament() {
      obs.trigger("dimmerChanged", 'active')
      var docRef = db.collection("tournaments").doc(opts.id)
      that.tournament['updatedAt'] = new Date()
      docRef.set(that.tournament)
      .then(function(docRef) {
        that.originalTournament = JSON.parse(JSON.stringify(that.tournament))
        that.message = { type: 'success', text: 'トーナメントデータを保存しました' }
      })
      .catch(function(error) {
        that.message = { type: 'error', text: 'トーナメント作成に失敗しました…' }
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
</edit-tournament>
