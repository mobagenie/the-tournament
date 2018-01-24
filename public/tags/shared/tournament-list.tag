<tournament-list>
  <table class="ui basic table" if={ items && items.length!=0 }>
    <tbody>
      <tr each={ item, index in items } if={ deletedList.indexOf(item.id) < 0 }>
        <td>
          <a href={ '/tournaments/'+item.id }>
            { item.data().title }
          </a>
          <br>
          <small>
            <i class="icon clock"></i>
            最終更新: { (item.data().updatedAt) ? formatDate(item.data().updatedAt, 'YYYY年MM月DD日 hh:mm') : '--' }
          </small>
        </td>
        <td class="right aligned" if={ editable }>
          <a class="ui icon primary basic button" href={ '/tournaments/'+item.id+'/edit' } data-tooltip="編集する" data-inverted="">
            <i class="icon setting"></i>
            編集
          </a>
          <div class="ui icon red basic button" data-tournament-id={ item.id } data-tooltip="削除する" data-inverted="" onclick={ removeTournament }><i class="icon trash"></i></div>
        </td>
      </tr>
    </tbody>
  </table>
  <div class="ui basic segment" if={ !items || items.length==0 }>
    <p>まだトーナメント表がありません...😢</p>

    <div class="ui red button" onclick={ createAndRedirectToTournament }>
      <i class="icon plus"></i>
      トーナメント表を作成する
    </div>
  </div>

  <div class="ui mini secondary menu">
    <div class="link item" onclick={ prevPage } if={ firstVisible }>
      <i class="icon chevron left"></i>
      Prev
    </div>
    <div class="right menu">
      <div class="link item" onclick={ nextPage } if={ lastVisible }>
        Next
        <i class="icon chevron right"></i>
      </div>
    </div>
  </div>


  <style>
    @media only screen and (max-width: 767px) {
      .ui.table:not(.unstackable) td:first-child, .ui.table:not(.unstackable) th:first-child small {
        font-weight: normal;
      }
    }
  </style>


  <script>
    /***********************************************
    * Settings
    ***********************************************/
    var that = this
    that.editable = opts.editable
    that.user = opts.user
    that.deletedList = []

    /* paging */
    that.items = null
    that.perPage = 25
    that.firstId = null
    that.lastVisible = null
    that.firstVisible = null


    /***********************************************
    * Observables
    ***********************************************/
    that.on('mount', function(){
      that.getItems({})
    })


    /***********************************************
    * Functions
    ***********************************************/
    /* トーナメントのIDだけ取得して新規作成画面に遷移 */
    createAndRedirectToTournament() {
      let newTnmtRef = db.collection("tournaments").doc()
      route('tournaments/' + newTnmtRef.id + '/edit')
    }

    formatDate(date, format) {
      if (!format) format = 'YYYY-MM-DD hh:mm:ss.SSS';
      format = format.replace(/YYYY/g, date.getFullYear());
      format = format.replace(/MM/g, ('0' + (date.getMonth() + 1)).slice(-2));
      format = format.replace(/DD/g, ('0' + date.getDate()).slice(-2));
      format = format.replace(/hh/g, ('0' + date.getHours()).slice(-2));
      format = format.replace(/mm/g, ('0' + date.getMinutes()).slice(-2));
      format = format.replace(/ss/g, ('0' + date.getSeconds()).slice(-2));
      if (format.match(/S/g)) {
        var milliSeconds = ('00' + date.getMilliseconds()).slice(-3);
        var length = format.match(/S/g).length;
        for (var i = 0; i < length; i++) format = format.replace(/S/, milliSeconds.substring(i, i + 1));
      }
      return format;
    }

    getItems(args) {
      obs.trigger("dimmerChanged", 'active')

      var docRef = db.collection("tournaments")
      // マイページ
      if(that.user) { docRef = docRef.where("userId", "==", that.user.uid) }
      // Next
      if(args.startAfter) {
        docRef = docRef.orderBy('updatedAt', 'desc').startAfter(args.startAfter)
      // Prev
      }else if(args.endBefore) {
        docRef = docRef.orderBy('updatedAt').startAfter(args.endBefore)
      // Initial
      }else {
        docRef = docRef.orderBy('updatedAt', 'desc')
      }
      docRef = docRef.limit(that.perPage)

      docRef.get().then(function(querySnapshot){
        that.items = querySnapshot.docs
        if(args.endBefore) { that.items = that.items.reverse() }

        // 最終ページ判定
        if(that.items.length >= that.perPage) {
          that.lastVisible = that.items[that.items.length-1]
        }else {
          that.lastVisible = null
        }

        // 最初にページアクセスしたときに、最初のIDを記録しておく
        if(Object.keys(args).length === 0) {
          that.firstId = that.items[0].id
        // ページ遷移時に、先頭まで戻ったかどうかの判定
        }else {
          if(that.firstId == that.items[0].id) {
            that.firstVisible = null
          }else {
            that.firstVisible = that.items[0]
          }
        }

        that.update()
        obs.trigger("dimmerChanged", '')
      })
    }

    nextPage() {
      that.getItems({startAfter: that.lastVisible})
    }

    prevPage() {
      that.getItems({endBefore: that.firstVisible})
    }

    removeTournament(e) {
      var ok = confirm('データを削除します。本当によろしいですか？')
      if(!ok) { return false }

      obs.trigger("dimmerChanged", 'active')
      var tournamentId = e.currentTarget.dataset.tournamentId

      db.collection("tournaments").doc(tournamentId).delete().then(function() {
        obs.trigger("dimmerChanged", '')
        that.deletedList.push(tournamentId)
        that.update()
      })
    }
  </script>
</tournament-list>
