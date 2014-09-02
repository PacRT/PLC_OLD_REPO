/**
 * Created by chiradip on 4/19/14.
 */

'use strict';


angular


    .module('app', ['ngRoute', 'angularFileUpload'])


    .config(function($routeProvider) {
        $routeProvider

            // route for the home page
            .when('/', {
                templateUrl : 'partials/upload-part',
                controller  : 'TestController'
            })

            // route for the about page
            .when('/landing', {
                templateUrl : 'partials/landing',
                controller  : 'TestController'
            })

            .when('/about', {
                templateUrl : 'partials/about',
                controller  : 'TestController'
            })

            .when('/register', {
                templateUrl : 'partials/register',
                controller  : 'TestController'
            })

            .when('/loginfailure', {
                templateUrl : 'partials/loginfailure',
                controller  : 'TestController'
            })

            .when('/registrationResponse', {
                templateUrl : 'partials/registrationResponse',
                controller  : 'TestController'
            })

            .when('/invite', {
                templateUrl : 'partials/invite',
                controller  : 'TestController'
            })

            .when('/dashboard', {
                templateUrl : 'partials/dashboard',
                controller  : 'DocumentsController'
            })

    })

    .controller('aboutController', function($scope) {
        $scope.message = 'Look! I am an about page.';
    })

    /*.controller('DocumentsController', function($scope, $http) {
        $http.get('/documents').success(function(data) {
            $scope.documents = data
        })
    })*/

    .controller('DocumentsController', function($scope, $http) {
        $scope.loadDocs = function() {
            $http.get('/documents').success(function (data) {
                $scope.documents = data
            })
        }
        $scope.loadDocs()
    })

    .controller('TestController', function ($scope, $fileUploader) {
        // Creates a uploader
        var uploader = $scope.uploader = $fileUploader.create({
            scope: $scope,
            url: '/upload/'
            //url: 'http://nervgh.github.io/pages/angular-file-upload/examples/image-preview/upload.php'
        });

        // ADDING FILTERS

        // Images and PDF only
        uploader.filters.push(function(item /*{File|HTMLInputElement}*/) {
            var type = uploader.isHTML5 ? item.type : '/' + item.value.slice(item.value.lastIndexOf('.') + 1);
            type = '|' + type.toLowerCase().slice(type.lastIndexOf('/') + 1) + '|';
            return '|jpg|png|jpeg|bmp|pdf|gif|'.indexOf(type) !== -1;
        });


        // REGISTER HANDLERS

        uploader.bind('afteraddingfile', function (event, item) {
            console.info('After adding a file', item);
        });

        uploader.bind('whenaddingfilefailed', function (event, item) {
            console.info('When adding a file failed', item);
        });

        uploader.bind('afteraddingall', function (event, items) {
            console.info('After adding all files', items);
        });

        uploader.bind('beforeupload', function (event, item) {
            console.info('Before upload', item);
        });

        uploader.bind('progress', function (event, item, progress) {
            console.info('Progress: ' + progress, item);
        });

        uploader.bind('success', function (event, xhr, item, response) {
            console.info('Success', xhr, item, response);
        });

        uploader.bind('cancel', function (event, xhr, item) {
            console.info('Cancel', xhr, item);
        });

        uploader.bind('error', function (event, xhr, item, response) {
            console.info('Error', xhr, item, response);
        });

        uploader.bind('complete', function (event, xhr, item, response) {
            console.info('Complete', xhr, item, response);
        });

        uploader.bind('progressall', function (event, progress) {
            console.info('Total progress: ' + progress);
        });

        uploader.bind('completeall', function (event, items) {
            console.info('Complete all', items);
            $scope.loadDocs();
        });
    });

