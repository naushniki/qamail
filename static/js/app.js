var app = angular.module('QaMail', []);
app.controller('mailboxController', function($scope, $http) {
    $scope.currentMailbox = null;
    $scope.sessionMailboxes = [];
    $scope.letters = [];

    $http({
        method: 'GET',
        url: '/api/list_mailboxes?session_key=' + sessionKey
    }).success(function(result) {
        parser = new X2JS();
        mailboxes = parser.xml_str2json(result).session.mailbox;
        $scope.sessionMailboxes = mailboxes;
        $scope.currentMailbox = $scope.sessionMailboxes[0];
        $scope.getLetters();
    });
    
    $scope.goToPreviousMailbox = function() {
        var current_index = $scope.sessionMailboxes.indexOf($scope.currentMailbox);
        if (current_index != $scope.sessionMailboxes.length - 1) {
            $scope.currentMailbox = $scope.sessionMailboxes[current_index + 1];
            $scope.getLetters();
        };
    };

    $scope.goToNextMailbox = function() {
        var current_index = $scope.sessionMailboxes.indexOf($scope.currentMailbox);
        if (current_index != 0) {
            $scope.currentMailbox = $scope.sessionMailboxes[current_index - 1];
            $scope.getLetters();
        };
    };

    $scope.createMailbox = function() {
        console.log('creating mailbox...');
        $http.put('/api/create_mailbox?session_key=' + sessionKey).success(function(result) {
            parser = new X2JS();
            mailbox = parser.xml_str2json(result).mailbox;
            $scope.sessionMailboxes = [mailbox].concat($scope.sessionMailboxes);
            $scope.currentMailbox = $scope.sessionMailboxes[0];
            $scope.getLetters();
        });

    };

    $scope.getLetters = function() {
        $http.get('/api/show_mailbox_content?session_key=' + sessionKey + '&address=' + $scope.currentMailbox.address).success(function(result) {
            parser = new X2JS();
            $scope.letters = parser.xml_str2json(result).mailbox.letter;
            console.log($scope.letters);
        })
    };

    $scope.emptyMailbox = function() {
        $http.delete('/api/empty_mailbox?session_key=' + sessionKey + '&address=' + $scope.currentMailbox.address).success(function(result) {
            $scope.letters = [];
            $scope.getLetters();
    });

    $scope.displayLetter = function(letter_id){
        console.log('displaying letter');
        $scope.currentLetter = letter;
        $("#letter_content")[0].src="/show_letter/session_key="+sessionKey+"&address="+currentMailbox.address+"&id="+letter.id+"&no_header";
        $("#letter_viewer")[0].setAttribute('display', 'show');
    };
};

});
