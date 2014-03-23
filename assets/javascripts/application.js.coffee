#=require ./jquery-2.1.0.min
#=require ./d3.min
#=require bootstrap

margin = { top: 20, right: 50, bottom: 20, left: 50 }
width = 1280 - margin.right - margin.left
height = 800 - margin.top - margin.left

tree = d3.layout.tree().size([height, width])
diagonal = d3.svg.diagonal().projection( (d) -> return [d.y, d.x])

i = 0
duration = 750
root = null

svg = d3.select('body').append('svg')
  .attr('width', width + margin.right + margin.left)
  .attr('height', height + margin.top + margin.bottom)
  .append('g')
  .attr('transform', 'translate(' + margin.left + ',' + margin.right + ')')

click = (d) ->
  if d.children
    d._children = d.children
    d.children = null
  else
    d.children = d._children
    d._children = null

  update(d)

update = (source) ->
  nodes = tree.nodes(root).reverse()
  links = tree.links(nodes)

  nodes.forEach( (d) -> d.y = d.depth * 180 )

  node = svg.selectAll('g.node').data(nodes, (d) -> d.id || (d.id = ++i))

  nodeEnter = node.enter().append('g')
    .attr('class', 'node')
    .attr('transform', (d) -> 'translate(' + source.y0 + ',' + source.x0 + ')')
    .on('click', click)

  nodeEnter.append('circle').attr('r', 1e-6).style('fill', (d) -> if d._children then 'lightsteelblue' else '#fff')

  nodeEnter.append('text')
    .attr('x', (d) -> if d.children || d._children then -10 else 10)
    .attr('dy', '.35em')
    .attr('text-anchor', (d) -> if d.children || d._children then 'end' else 'start')
    .text((d) -> d.name)
    .style('fill-opacity', 1e-6)

  nodeUpdate = node.transition()
    .duration(duration)
    .attr('transform', (d) -> 'translate(' + d.y + ',' + d.x + ')')

  nodeUpdate.select('circle')
    .attr('r', 4.5)
    .style('fill', (d) -> if d._children then 'lightsteelblue' else '#fff')

  nodeUpdate.select('text').style('fill-opacity', 1)

  nodeExit = node.exit().transition()
    .duration(duration)
    .attr('transform', (d) -> 'translate(' + source.y + ',' + source.x + ')')
    .remove()

  nodeExit.select('circle').attr('r', 1e-6)

  nodeExit.select('text').style('fill-opacity', 1e-6)

  link = svg.selectAll('path.link').data(links, (d) -> d.target.id)

  link.enter().insert('path', 'g')
    .attr('class', 'link')
    .attr('d', (d) ->
      o = { x: source.x0, y: source.y0 }
      diagonal({ source: o, target: o })
      )

  link.transition()
    .duration(duration)
    .attr('d', diagonal)

  link.exit().transition()
    .duration(duration)
    .attr('d', (d) ->
      o = { x: source.x, y: source.y }
      diagonal({ source: o, target: o })
      )
    .remove()

  nodes.forEach((d) ->
    d.x0 = d.x
    d.y0 = d.y
    )

$('#showBtn').click( ->
  d3.json('/getjson?url=' + $('#urlInput').val(), (error, data) ->
    return unless data.status

    root = data.tree
    root.x0 = height / 2
    root.y0 = 0

    collapse = (d) ->
      return unless d.children
      d._children = d.children
      d._children.forEach collapse
      d.children = null

    update(root)
  )
)
