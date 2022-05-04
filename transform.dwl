%dw 2.0
input svg application/xml
output application/xml
ns ns0 http://www.w3.org/2000/svg
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
    { (progressBar(50)), (key): value }
  else
    { (key): value }

fun progressBar(percent) = {
  rect @(width:"200", height:"14",y: "-1.0", style: "fill: rgba(200,200,200,200);stroke-width:1;stroke:rgb(0,0,0)"): {},
  rect @(width:((percent / 100) * 200) as String, height:"14",y: "-1.0", style: "fill:rgb(0,255,88);stroke-width:1;stroke:rgb(0,0,0)"): {}
}

---
svg: traverse(svg, [])