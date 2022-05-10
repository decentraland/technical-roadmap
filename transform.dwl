%dw 2.0

// This script uses data from raw-data.dwl and it generates an image out of it
// and the excalidraw file

input svg application/xml
input data application/dw
output application/xml
ns ns0 http://www.w3.org/2000/svg
ns xlink http://www.w3.org/1999/xlink
var expr = /([^\/]+)\/([^\/]+)#(\d+)/

fun traverse(obj, parent) =
  obj match {
    case t is Object -> mapObject(t, (value, key, index) -> key match {
      case "text" -> processTextField(key, value, parent)
      else -> { (key): traverse(value, [key ~ parent]) }
    })
    else -> obj
  }

fun processTextField(key, value, parents) =
  if (value matches expr)
    { (progressBarSlug(key, value)) }
  else
    { (key): value }

fun progressBar(key, result) = do {
  var percent = result.completion
  ---
  {
    rect @(width:"200", height:"14",y: "-1.0", style: "fill: rgba(200,200,200,200);stroke-width:1;stroke:rgb(0,0,0)"): {},
    rect @(width:((percent / 100) * 200) as String, height:"14",y: "-1.0", style: "fill:rgb(0,255,88);stroke-width:1;stroke:rgb(0,0,0)"): {},
    a @(xlink#href: result.link, target: "_blank") : {
      (key): result.slug ++ " - " ++ floor(percent) as String ++ "%"
    }
  }
}

fun progressBarSlug(key, slug) = data.state[slug] match {
  case obj is Object -> progressBar(key, data.state[slug])
  else -> progressBar(0, {completion: 0, slug: slug, link: ""})
}

---
traverse(svg, [])