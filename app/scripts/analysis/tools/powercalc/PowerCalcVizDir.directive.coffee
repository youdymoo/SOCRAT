'use strict'

BaseDirective = require 'scripts/BaseClasses/BaseDirective'

module.exports = class PowercalcVizDiv extends BaseDirective
    @inject '$parse'

    initialize: ->
        @link = (scope, elem, attr) =>
            scope.$watch '[mainArea.twoTest]', (newDataPoints) =>
                return


            drawNormalCurve: (mean_in1, variance_in1, sigma_in1, mean_in2, variance_in2, sigma_in2, alpha_in) ->
                margin = {top: 20, right: 20, bottom: 20, left:20}
                width = 500 - margin.left - margin.right
                height = 500 - margin.top - margin.bottom
                container = d3.select("#twoTestGraph")
                container.select("svg").remove()
                svg = container.append('svg')
                .attr("width", width + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom)
                _graph = svg.append('g')
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
                mean1 = mean_in1
                variance1 = variance_in1
                standardDerivation1 =  sigma_in1

                mean2 = mean_in2
                variance2 = variance_in2
                standardDerivation2 = sigma_in2

                rightBound = Math.max(@getRightBound(mean1, standardDerivation1), @getRightBound(mean2, standardDerivation2))
                leftBound = Math.min(@getLeftBound(mean1, standardDerivation1), @getLeftBound(mean2, standardDerivation2))
                bottomBound = 0
                topBound = Math.max(1 / (standardDerivation1 * Math.sqrt(Math.PI * 2)), 1 / (standardDerivation2 * Math.sqrt(Math.PI * 2)))
                gaussianCurveData1 = @getGaussianFunctionPoints(standardDerivation1,mean1,variance1,leftBound,rightBound)
                gaussianCurveData2 = @getGaussianFunctionPoints(standardDerivation2,mean2,variance2,leftBound,rightBound)

                radiusCoef = 5

                padding = 50
                xScale = d3.scale.linear().range([0, width]).domain([leftBound, rightBound])
                #console.log "xScale: " + xScale
                yScale = d3.scale.linear().range([height-padding, 0]).domain([bottomBound, topBound])

                xAxis = d3.svg.axis().ticks(10)
                .scale(xScale)

                yAxis = d3.svg.axis()
                .scale(yScale)
                .ticks(10)
                .tickPadding(0)
                .orient("right")

                lineGen = d3.svg.line()
                .x (d) -> xScale(d.x)
                .y (d) -> yScale(d.y)
                .interpolate("basis")


                # data1
                path1 = _graph.append('svg:path')
                .attr('d', lineGen(gaussianCurveData1))
                .data([gaussianCurveData1])
                .attr('stroke', 'black')
                .attr('stroke-width', 5)
                .attr('fill', "blue")
                .style("opacity", 0.5)

                # data2
                path2 = _graph.append('svg:path')
                .attr('d', lineGen(gaussianCurveData2))
                .data([gaussianCurveData2])
                .attr('stroke', 'red')
                .attr('stroke-width', 5)
                .attr('fill', "chocolate")
                .style("opacity", 0.5)

                # x-axis
                _graph.append("svg:g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + (height - padding) + ")")
                .call(xAxis)

                # y-axis
                _graph.append("svg:g")
                .attr("class", "y axis")
                .attr("transform", "translate(" + (xScale(leftBound))+ ",0)")
                .call(yAxis)

                # make x y axis thin
                _graph.selectAll('.x.axis path')
                .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})
                _graph.selectAll('.y.axis path')
                .style({'fill' : 'none', 'stroke' : 'black', 'shape-rendering' : 'crispEdges', 'stroke-width': '1px'})

                # display lengend1
                svg.append("text")
                .attr("id", "displayLegend1")
                .attr("x", xScale(rightBound*0.9))
                .attr("y", yScale(topBound*0.9))
                .style("text-anchor", "middle")
                .attr('fill', "blue");

                # display legend2
                svg.append("text")
                .attr("id", "displayLegend2")
                .attr("x", xScale(rightBound*0.9))
                .attr("y", yScale(topBound*0.85))
                .style("text-anchor", "middle")
                .attr('fill', "chocolate");

                # rotate text on x axis
                # _graph.selectAll('.x.axis text')
                # .attr('transform', (d) ->
                #    'translate(' + this.getBBox().height*-2 + ',' + this.getBBox().height + ')rotate(-40)')
                # .style('font-size', '16px')

                return
