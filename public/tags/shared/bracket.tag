<bracket>
  <div id="bracket" class="bracket { skipConsolation: !tournament.consolationRound, scoreLess: tournament.scoreLess, showBye: showBye, editable: editable, embed: embed, profileImages: embed && tournament.profileImages }" tabindex="0">
    <div class="block left">
      <div class="round { final: isFinalRound(roundIndex) }" each={ round, roundIndex in tournament.results }>
        <div class="match { matchClass(roundIndex, matchIndex) } { matchFlex(roundIndex, matchIndex) }" each={ match, matchIndex in round } data-round-index={ roundIndex } data-match-index={ matchIndex } tabindex={ match['bye'] && roundIndex!=0 ? false : 0 }>
          <div class="teamContainer { teamContainerPosition(roundIndex, matchIndex) }">
            <div class="team { teamClass(match, i) }" data-teamid={ teamIndex } each={ teamIndex, i in matchTeamIndexes(roundIndex, matchIndex) }>
              <span class="winnerSelect" if={ editable }>
                <input type="radio" name="winner_{ roundIndex }_{ matchIndex }" data-round-index={ roundIndex } data-match-index={ matchIndex } value={ i } checked={ i == match['winner'] } onclick={ updateWinner } disabled={ match.bye }>
              </span>

              <div class="profileImage { profileIconClass(teamIndex) }" if={ embed && tournament.profileImages }></div>

              <div class="name { (editable) ? 'ui transparent input' : '' }" style={ (embed) ? false : nameWidth() }>
                <i class="flag { tournament.teams[teamIndex]['country'] }" if={ teamIndex != null && tournament.teams[teamIndex]['country'] }></i>
                <input type="text" if={ editable } data-teamid={ teamIndex } value={ teamName(teamIndex) } onchange={ updateTeamName } disabled={ teamIndex == null }>
                <span if={ !editable }>{ teamName(teamIndex) }</span>
              </div>

              <div class="score { (editable) ? 'ui transparent input' : '' }" style={ (embed) ? false : scoreWidth() }>
                <input type="text" if={ editable } data-round-index={ roundIndex } data-match-index={ matchIndex } data-team-order={ i } value={ match.score[i] } onchange={ updateScore }>
                <span if={ !editable }>{ match.score[i] }</span>
              </div>

              <i class="icon link remove circle" if={ editable && roundIndex==0 && teamName(teamIndex)!='' } onclick={ removeTeam } data-teamid={ teamIndex }></i>
            </div>
          </div>

          <div class="lineContainer">
            <div class="line-flex-{ lineFlex(roundIndex, matchIndex)[0] }">
              <div></div>
              <div></div>
            </div>
            <div class="line-flex-{ lineFlex(roundIndex, matchIndex)[1] }">
              <div></div>
              <div></div>
            </div>
          </div>

          <div class="popupContainer" if={ !editable }>
            <div class="popupContent">
              <h3 class="popupTitle">
                { roundMatchLabel(roundIndex, matchIndex) }
              </h3>
              <div class="popupTeamContainer">
                <virtual each={ i in [0,1] }>
                  <div class="popupTeam { teamClass(match, i) }" each={ teamIndex in [getTeamIndex(tournament, roundIndex, matchIndex, i)] }>
                    <div class="popupName">
                      { teamName(teamIndex) }
                    </div>
                    <div class="popupScore">
                      { match.score[i] }
                    </div>
                  </div>
                  <div class="popupSpacer" if={ i == 0 }>
                    -
                  </div>
                </virtual>
              </div>
              <div data-is="raw" class="popupComment" if={ !embed } content={ match.comment }></div>
              <div if={ embed } class="popupComment">{ match.comment }</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>


  <style>
    /* ???????????????????????? */
    .name input, .score input { height: 25px; }
    .score input { text-align: center !important; }
    .winnerSelect {
      height: 25px;
      width: 25px;
      line-height: 25px;
      background: rgba(255,255,255,0.4);
      padding: 0 5px;
    }

    /* ??????????????????????????? */
    .editable.bracket:focus-within:after { display: none; }
    .editable.bracket .match { cursor: default; }

    /* team??????????????? */
    .icon.link.remove.circle {
      color: #999;
      position: absolute;
      right: -20px;
    }

    /* ???????????????????????? */
    .editable.bracket .match:not(.final):not(.consolation) .team.loser:not(.highlight) { opacity: 1; }

    /* ????????????????????? */
    .bracket.showBye .match.skip { display: flex; }
    .bracket.showBye .match {
      flex: 1 1 auto !important;
    }
    .bracket.showBye .round:not(:first-child) .match.bye .teamContainer { display: block; }
    .bracket.showBye .teamContainer { top: unset !important; }
    .bracket.showBye .lineContainer div { flex-grow: 1 !important; }
    .bracket.showBye .lineContainer > div > div { width: 20px !important; }
    .bracket.showBye .left.block .match.next-bye:nth-child(odd) .lineContainer > div:last-child > div:first-child,
    .bracket.showBye .left.block .match.next-bye:nth-child(even) .lineContainer > div:first-child > div:first-child {
      border-right: 2px solid #999 !important;
    }
    .bracket.showBye .left.block .match.next-bye:nth-child(odd) .lineContainer > div:last-child > div:last-child {
      border-bottom: 1px solid #999;
      border-top: none !important;
    }
    .bracket.showBye .left.block .match.next-bye:nth-child(even) .lineContainer > div:first-child > div:last-child {
      border-top: 1px solid #999;
      border-bottom: none !important;
    }

    /* ????????? */
    small { margin-left: 10px; }
  </style>


  <script>
    /***********************************************
    * Settings
    ***********************************************/
    var that = this
    that.tournament = opts.tournament
    that.editable = opts.editable
    that.embed = opts.embed
    that.showBye = false


    /***********************************************
    * Functions
    ***********************************************/
    isFinalRound(roundIndex) {
      return roundIndex == Object.keys(that.tournament.results).length - 1
    }

    nameWidth() {
      return 'width: ' + that.tournament.nameWidth + 'px'
    }
    scoreWidth() {
      return 'width: ' + that.tournament.scoreWidth + 'px'
    }

    matchTeamIndexes(roundIndex, matchIndex) {
      return {
        0: that.getTeamIndex(that.tournament, roundIndex, matchIndex, 0),
        1: that.getTeamIndex(that.tournament, roundIndex, matchIndex, 1)
      }
    }

    profileIconClass(teamIndex) {
      if(teamIndex != null) {
        return "icon-" + ('000' + Number(teamIndex+1)).slice(-3)
      }else {
        return "icon-dummy"
      }
    }

    updateScore(e) {
      var roundIndex = Number(e.currentTarget.getAttribute('data-round-index'))
      var matchIndex = Number(e.currentTarget.getAttribute('data-match-index'))
      var teamOrder = Number(e.currentTarget.getAttribute('data-team-order'))
      that.tournament.results[roundIndex][matchIndex]['score'][teamOrder] = e.currentTarget.value
      obs.trigger("tournamentChanged", that.tournament)
    }

    updateTeamName(e) {
      var teamIndex = Number(e.currentTarget.getAttribute('data-teamid'))
      that.tournament.teams[teamIndex]['name'] = e.currentTarget.value
      that.updateByeGames(that.tournament)

      obs.trigger("tournamentChanged", that.tournament)
    }

    updateTournament(e) {
      attribute = e.target.name
      value = (e.target.type != 'checkbox') ? e.target.value : e.target.checked
      that.tournament[attribute] = value
      obs.trigger("tournamentChanged", that.tournament)
    }

    updateWinner(e) {
      var roundIndex = Number(e.currentTarget.getAttribute('data-round-index'))
      var matchIndex = Number(e.currentTarget.getAttribute('data-match-index'))

      var targetWinner = that.tournament.results[roundIndex][matchIndex]['winner']
      var newWinner = Number(e.currentTarget.value)

      that.tournament.results[roundIndex][matchIndex]['winner'] = (targetWinner == newWinner) ? null : newWinner
      obs.trigger("tournamentChanged", that.tournament)
    }

    teamName(teamIndex) {
      return (teamIndex==null) ? '--' : that.tournament.teams[teamIndex]['name']
    }

    matchClass(roundIndex, matchIndex) {
      var roundIndex = Number(roundIndex)
      var matchIndex = Number(matchIndex)
      var matchClass = ""

      // ??????????????????
      if(roundIndex == Object.keys(that.tournament.results).length - 1) {
        if(matchIndex==0) {
          matchClass = 'final'
        }else {
          matchClass = 'consolation'
        }
      // ????????????
      }else {
        if( that.highlightMatch(roundIndex, 1) == matchIndex ) {
          matchClass = 'highlightFirst'
        }else if( that.highlightMatch(roundIndex, 2) == matchIndex ) {
          matchClass = 'highlightSecond'
        }
      }

      /* bye/skip???????????? */
      var result = that.tournament.results[roundIndex][matchIndex]
      if(result['bye'] && result['winner']!=null) {
        matchClass += ' bye'
      }else if(result['bye'] && result['winner']==null) {
        matchClass += ' skip'
      }
      /* next-bye???????????? */
      var pairMatchIndex = (matchIndex%2==0) ? matchIndex + 1 : matchIndex - 1
      var pairResult = that.tournament.results[roundIndex][pairMatchIndex]
      if(pairResult['bye'] && pairResult['winner']==null) {
        matchClass += ' next-bye'
      }

      return matchClass
    }

    /*  match???flex = (round:0???skip???????????????????????????) ????????? */
    matchFlex(roundIndex, matchIndex) {
      /* ????????? */
      if( roundIndex == 0 ) { return 'match-flex-0' }
      /* ?????????????????? */
      if( roundIndex == Object.keys(that.tournament.results).length-1 ) { return '' }

      var start = matchIndex * Math.pow(2, roundIndex)
      var end = start + Math.pow(2, roundIndex) - 1

      var count = 0
      for(var i = start; i <= end; i++) {
        var res = that.tournament.results[0][i]
        if(!res['bye'] || res['winner']!=null) { count += 1 }
      }
      return 'match-flex-' + count
    }

    /* ????????????????????????????????????lineContainer???flex-grow???????????? */
    lineFlex(roundIndex, matchIndex) {
      var res = that.tournament.results[roundIndex][matchIndex]
      // ????????????skip?????????1:1
      if(roundIndex==0 || (res['bye'] && res['winner']==null)) {
        return [1, 1]
      // bye????????????????????????????????????
      }else if(res['bye'] && res['winner'] != null) {
        // ????????????????????????????????????????????????matchIndex*2???res['winner']?????????
        return that.lineFlex(roundIndex - 1, matchIndex * 2 + res['winner'])
      }

      var children = that.childrenMatchCount(roundIndex, matchIndex)
      return [Math.max(children[0], 1), Math.max(children[1], 1)]
    }

    /* ??????????????????????????????????????????????????????????????????????????????????????? */
    childrenMatchCount(roundIndex, matchIndex) {
      var count = [0,0]

      /* ???????????????????????? */
      if(roundIndex==0) { return count }
      /* 3???????????? */
      if(roundIndex==Object.keys(that.tournament.results).length-1 && matchIndex==1 ) {
        return count
      }

      var start = matchIndex * Math.pow(2, roundIndex)
      var end = start + Math.pow(2, roundIndex) - 1
      var middle = Math.floor((end - start) / 2) + start

      for(var i = start; i <= middle; i++) {
        var res = that.tournament.results[0][i]
        if(!res['bye'] || res['winner']!=null) { count[0] += 1 }
      }
      for(var i = middle+1; i <= end; i++) {
        var res = that.tournament.results[0][i]
        if(!res['bye'] || res['winner']!=null) { count[1] += 1 }
      }

      return count
    }

    calcMatchPosition(roundIndex, matchIndex) {
      /* ???????????????????????? */
      if(roundIndex==0) { return 0 }
      /* 3????????????????????????????????????????????? */
      if(roundIndex==Object.keys(that.tournament.results).length-1 && matchIndex==1 ) {
        matchIndex = 0
      }

      var count = that.childrenMatchCount(roundIndex, matchIndex)
      return count[0] - count[1]
    }

    teamContainerPosition(roundIndex, matchIndex) {
      var position = that.calcMatchPosition(roundIndex, matchIndex)
      return 'team-position-' + position
    }

    teamClass(match, teamOrder) {
      if(match.winner==null) { return '' }
      return (match.winner == teamOrder) ? 'winner' : 'loser'
    }

    /* ??????/?????????????????????????????????match(??????????????????)  e.g. ?????????ID=13????????????round:1 ?????? 13 / 2**1 ).ceil = 7 */
    highlightMatch(roundIndex, rank) {
      // that.tournament.results
      var targetTeamIndex = that.finalTeam(rank)
      if(targetTeamIndex==null) {
        return null
      }
      return Math.floor( targetTeamIndex / Math.pow(2, Number(roundIndex)+1) )
    }

    /* ??????????????????????????????ID????????? */
    finalTeam(rank) {
      var finalRoundIndex = Object.keys(that.tournament.results).length - 1
      var finalMatch = that.tournament.results[finalRoundIndex][0]

      if(finalMatch['winner']==null) {
        return null
      }

      var targetIndex = (rank==1) ? finalMatch['winner'] : 1 - finalMatch['winner']
      var teamIndex = that.getTeamIndex(that.tournament, finalRoundIndex, 0, targetIndex)
      return teamIndex
    }

    /* hover?????????????????? */
    highlightTeam(e) {
      var teams = document.getElementsByClassName('team');
      e.currentTarget.classList.add("highlight");  // id?????????????????????(TBD??????)??????????????????????????????????????????

      var teamid = e.currentTarget.dataset.teamid;
      var selectedTeams = document.querySelectorAll('[data-teamid="'+ teamid +'"]');
      for (var j = 0; j < selectedTeams.length; j++) {
        selectedTeams[j].classList.add("highlight");

        // winner????????????match??????highlight?????????lineContainer??????????????????
        if(selectedTeams[j].classList.contains('winner')) {
          var match = selectedTeams[j].parentNode.parentNode;
          match.classList.add("highlight");
        }
      }
    }
    resetHighlight(e) {
      var teams = document.getElementsByClassName('team');
      for (var k = 0; k < teams.length; k++) {
        teams[k].classList.remove("highlight");

        var match = teams[k].parentNode.parentNode;
        match.classList.remove("highlight");
      }
    }

    teamClass(match, teamOrder) {
      if(match.winner==null) { return '' }
      return (match.winner == teamOrder) ? 'winner' : 'loser'
    }

    roundName(roundIndex) {
      var roundName = ''
      if(roundIndex == Object.keys(that.tournament.results).length-1) {
        roundName = '??????????????????'
      }else {
        roundName = (roundIndex+1) + '??????'
      }
      return roundName
    }

    matchName(roundIndex, matchIndex) {
      var matchName = ''
      if(roundIndex == Object.keys(that.tournament.results).length-1) {
        matchName = (matchIndex==0) ? '?????????' : '3????????????'
      }else {
        matchName = '???' + (matchIndex+1) + '??????'
      }
      return matchName
    }

    roundMatchLabel(roundIndex, matchIndex) {
      let roundMatchLabel = ""
      let match = that.tournament.results[Number(roundIndex)][Number(matchIndex)]
      if(match.label && match.label != "") {
        roundMatchLabel = match.label
      }else {
        let roundLabel = (Number(roundIndex) == Object.keys(that.tournament.results).length-1) ? '' : that.roundName(Number(roundIndex))
        let matchLabel = that.matchName(Number(roundIndex), Number(matchIndex))
        roundMatchLabel = roundLabel + matchLabel
      }
      return roundMatchLabel
    }

    removeTeam(e) {
      var teamIndex = e.currentTarget.getAttribute('data-teamid')
      that.tournament.teams[teamIndex] = { name: '' }
      that.updateByeGames(that.tournament)

      obs.trigger("tournamentChanged", that.tournament)
    }


    /***********************************************
    * Mixin (only for SSR)
    * FIXME: mixin????????????????????????????????????
    ***********************************************/
    /* ??????????????????????????????????????? */
    getTeamIndex(tournament, roundIndex, matchIndex, teamOrder) {
      var isConsolation = (roundIndex == Object.keys(tournament.results).length - 1) && (matchIndex == 1)
      // 1??????
      if(roundIndex==0) {
        teamIndex = ( matchIndex * 2 ) + teamOrder
        return teamIndex
      // 2????????????
      }else {
        prevMatchIndex = (isConsolation) ? teamOrder : ( matchIndex * 2 ) + teamOrder
        prevResult = tournament.results[roundIndex-1][prevMatchIndex]
        // ???????????????????????????????????????????????????????????????????????????
        if(prevResult['winner']!=null) {
          prevWinnerIndex = (isConsolation) ? 1 - prevResult['winner'] : prevResult['winner']
          return that.getTeamIndex(tournament, roundIndex-1, prevMatchIndex, prevWinnerIndex)
        // ??????????????????????????????????????????
        }else {
          return null
        }
      }
    }
  </script>
</bracket>
