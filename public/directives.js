/**
 * Created by chiradip on 4/19/14.
 */

'use strict';


angular


    .module('app')


    // Angular File Upload module does not include this directive
    // Only for example


/**
 * The ng-thumb directive
 * @author: nerv
 * @version: 0.1.2, 2014-01-09
 */
    .directive('ngThumb', ['$window', function($window) {
        var helper = {
            support: !!($window.FileReader && $window.CanvasRenderingContext2D),
            isFile: function(item) {
                return angular.isObject(item) && item instanceof $window.File;
            },
            isImage: function(file) {
                var type =  '|' + file.type.slice(file.type.lastIndexOf('/') + 1) + '|';
                return '|jpg|png|jpeg|bmp|gif|'.indexOf(type) !== -1;
            },
            isPdf: function(file) {
                var type =  '|' + file.type.slice(file.type.lastIndexOf('/') + 1) + '|';
                return '|pdf|'.indexOf(type) !== -1;
            }
        };

        return {
            restrict: 'A',
            template: '<canvas/>',
            link: function(scope, element, attributes) {
                if (!helper.support) return;

                var params = scope.$eval(attributes.ngThumb);

                if (!helper.isFile(params.file)) return;
                if (!helper.isImage(params.file) && !helper.isPdf(params.file)) return;

                var canvas = element.find('canvas');

                /**canvas[0].addEventListener("mousedown", showBigger, false);

                function showBigger(event) {
                    console.info("test test")
                    //canvas.attr({width: 100, height: 100})
                    PDFJS.getDocument(dataUrl).then(function(pdf) {
                        pdf.getPage(1).then(function(page) {
                            var viewport = page.getViewport(3.5);
                            var width = 5000; //params.width || this.width / this.height * params.height;
                            var height = 3500; //params.height || this.height / this.width * params.width;
                            var context = canvas[0].getContext('2d')
                            canvas.attr({ width: width, height: height });
                            var renderContext = {
                                canvasContext: context,
                                viewport: viewport
                            };
                            page.render(renderContext);
                        })
                    })
                } **/

                var reader = new FileReader();

                reader.onload = onLoadFile;
                reader.readAsDataURL(params.file);

                var dataUrl = URL.createObjectURL(params.file);

                function onLoadFile(event) {
                    if (helper.isImage(params.file)) {
                        var img = new Image();
                        img.onload = onLoadImage;
                        img.src = event.target.result;
                    } else if (helper.isPdf(params.file)) {
                        PDFJS.getDocument(dataUrl).then(function(pdf) {
                            pdf.getPage(1).then(function(page) {
                                var viewport = page.getViewport(0.5);
                                var width = params.width || this.width / this.height * params.height;
                                var height = params.height || this.height / this.width * params.width;
                                var context = canvas[0].getContext('2d')
                                canvas.attr({ width: width, height: height });
                                var renderContext = {
                                    canvasContext: context,
                                    viewport: viewport
                                };
                                page.render(renderContext);
                            })
                        })
                    }

                }

                function onLoadImage() {
                    var width = params.width || this.width / this.height * params.height;
                    var height = params.height || this.height / this.width * params.width;
                    canvas.attr({ width: width, height: height });
                    canvas[0].getContext('2d').drawImage(this, 0, 0, width, height);
                }
            }
        };
    }]);

