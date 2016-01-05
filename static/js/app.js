var app = angular.module('QaMail', []);

var parse = function(xml) {
    parser = new X2JS();
    return parser.xml_str2json(xml);
};

app.controller('mailboxController', function($scope, $http, $window, $httpParamSerializer) {
    $scope.currentMailbox = null;
    $scope.sessionMailboxes = [];
    $scope.letters = [];
    $scope.loadedLetters = {};
    $scope.show_letter_viewer = false;

    $http({
        method: 'GET',
        url: '/api/list_mailboxes?session_key=' + sessionKey
    }).success(function(result) {
        mailboxes = [].concat(parse(result).session.mailbox);
        $scope.sessionMailboxes = mailboxes;
        $scope.currentMailbox = $scope.sessionMailboxes[0];
        $scope.getLetters();
    });

    $scope.goToPreviousMailbox = function() {
        $scope.show_letter_viewer = false;
        var current_index = $scope.sessionMailboxes.indexOf($scope.currentMailbox);
        if (current_index != $scope.sessionMailboxes.length - 1) {
            $scope.currentMailbox = $scope.sessionMailboxes[current_index + 1];
            $scope.getLetters();
        };
    };

    $scope.goToNextMailbox = function() {
        $scope.show_letter_viewer = false;
        var current_index = $scope.sessionMailboxes.indexOf($scope.currentMailbox);
        if (current_index != 0) {
            $scope.currentMailbox = $scope.sessionMailboxes[current_index - 1];
            $scope.getLetters();
        };
    };

    $scope.createMailbox = function() {
        $scope.show_letter_viewer = false;
        console.log('creating mailbox...');
        $http.put('/api/create_mailbox?session_key=' + sessionKey).success(function(result) {
            mailbox = parse(result).mailbox;
            $scope.sessionMailboxes = [mailbox].concat($scope.sessionMailboxes);
            $scope.currentMailbox = $scope.sessionMailboxes[0];
            $scope.getLetters();
        });

    };

    $scope.getLetters = function() {
        $scope.letters = [];
        $scope.show_letter_list_preloader = true;
        $scope.this_mailbox_is_empty = false;
        $http.get('/api/show_mailbox_content?session_key=' + sessionKey + '&address=' + $scope.currentMailbox.address).success(function(result) {
            parsed_letters = parse(result).mailbox.letter;
            if (parsed_letters != null) {
                $scope.letters = $scope.letters.concat(parse(result).mailbox.letter);
            };
            if ($scope.letters.length === 0) {
                $scope.this_mailbox_is_empty = true;
            };
            for (i = 0; i < $scope.letters.length; i++) {
                if ($scope.letters[i]) {
                    $scope.letters[i].date = (new Date($scope.letters[i].date.replace(/-/g, '/'))).toString(); // Convert letters' dates to local time zone
                };
            };
            $scope.show_letter_list_preloader = false;
            console.log('loaded letters for ' + $scope.currentMailbox.address);
        });
    };

    $scope.emptyMailbox = function() {
        $scope.show_letter_viewer = false;
        $http.delete('/api/empty_mailbox?session_key=' + sessionKey + '&address=' + $scope.currentMailbox.address).success(function(result) {
            $scope.letters = [];
            $scope.getLetters();
        });
    };

    $scope.loadLetter = function(letter) {
        return new Promise(function(resolve, reject) {
            if (($scope.loadedLetters[letter.id] === undefined) === false) {
                resolve();
            } else {
                console.log('loading letter "' + letter.subject + '"');
                $http.get('/api/show_rendered_letter?session_key=' + sessionKey + '&address=' + $scope.currentMailbox.address + '&letter_id=' + letter.id).success(function(result) {
                    $scope.loadedLetters[letter.id] = parse(result).letter;
                    console.log('loaded letter "' + letter.subject + '"');
                    resolve();
                });
            };
        });
    };

    $scope.displayLetter = function(letter) {
        console.log('displaying letter "' + letter.subject + '"');
        $(".letter-control-button").addClass("pure-button-disabled");
        $scope.currentLetter = letter;
        $scope.show_letter_viewer = true;
        document.getElementById("letter_content").contentWindow.document.close();
        document.getElementById("letter_content").contentWindow.document.write('<br><br><center><h1 style="font-family: sans-serif;"><font color="gray">Loading...</font></h1></center>');
        $scope.loadLetter(letter).then(function(response) {
            if ($scope.currentLetter == letter){
                if ($scope.loadedLetters[letter.id]['html_content'] !== undefined) {
                    $("#html-button").removeClass("pure-button-disabled");
                };
                if ($scope.loadedLetters[letter.id]['plain_text_content'] !== undefined) {
                    $("#plain-text-button").removeClass("pure-button-disabled");
                };
                $("#raw-button").removeClass("pure-button-disabled");
                $("#reply-button").removeClass("pure-button-disabled");

                if ($scope.loadedLetters[letter.id]['html_content'] !== undefined) {
                    $scope.displayHtmlLetter(letter);
                } else if ($scope.loadedLetters[letter.id]['plain_text_content'] !== undefined) {
                    $scope.displayPlainTextLetter(letter);
                } else {
                    $scope.displayRawLetter(letter);
                };
            };
        });
    };

    $scope.displayRawLetter = function(letter) {
        if ($scope.loadedLetters[letter.id]['raw_content'] != undefined) {
            $(".letter-control-button").removeClass("pure-button-active");
            $("#raw-button").addClass("pure-button-active");
            document.getElementById("letter_content").contentWindow.document.close();
            document.getElementById("letter_content").contentWindow.document.write($scope.loadedLetters[letter.id]['raw_content']);
        };
    };

    $scope.displayPlainTextLetter = function(letter) {
        if ($scope.loadedLetters[letter.id]['plain_text_content'] != undefined) {
            $(".letter-control-button").removeClass("pure-button-active");
            $("#plain-text-button").addClass("pure-button-active");
            document.getElementById("letter_content").contentWindow.document.close();
            document.getElementById("letter_content").contentWindow.document.write($scope.loadedLetters[letter.id]['plain_text_content']);
        };
    };

    $scope.displayHtmlLetter = function(letter) {
        if ($scope.loadedLetters[letter.id]['html_content'] != undefined) {
            $(".letter-control-button").removeClass("pure-button-active");
            $("#html-button").addClass("pure-button-active");
            document.getElementById("letter_content").contentWindow.document.close();
            document.getElementById("letter_content").contentWindow.document.write($scope.loadedLetters[letter.id]['html_content']);
        };
    };

    $scope.fillReplyForm = function() {
        $scope.replySendersName = null;
        $scope.replyToAddress = $scope.currentLetter.from;
        $scope.replyCC = null;
        $scope.replySubject = "Re: "+$scope.currentLetter.subject;
        $scope.replyText = '';
        if ($scope.loadedLetters[$scope.currentLetter.id]['plain_text_for_reply'] != undefined) {
            $scope.replyText +='\n\n';
            $scope.replyText +='On ' + $scope.currentLetter.date + ' you wrote:\n-----------\n';
            $scope.replyText +=  $scope.loadedLetters[$scope.currentLetter.id]['plain_text_for_reply'];
        };
        $window.location.href = '#reply';
    };

    $scope.sendReply = function() {
        $http({
            method: 'POST',
            url: '/send_reply',
            paramSerializer: '$httpParamSerializerJQLike',
            params: {
                from_address: $scope.currentMailbox.address,
                sender: $scope.replySendersName,
                to: $scope.replyToAddress,
                CC: $scope.replyCC,
                subject: $scope.replySubject,
                message: $scope.replyText,
                session_key: sessionKey
            }
        }).success(function(result) {
            $window.location.href = '#close';
        });

    };
});
