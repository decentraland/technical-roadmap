%dw 2.0
// This file finds the repo/issue#111 from the SVG and fetches github
// to get the necessary information to create the final SVG

import * from dw::io::http::Client
// https://github.com/mulesoft/data-weave-io/blob/master/http-netty-module/src/test/dwmit/GET_POST/transform.dwl

input svg application/xml
output application/dw

/**
 * Finds issues from the whole SVG
 */
var issues = svg..text map ($ match {
  case parts matches /([^\/]+)\/([^\/]+)#(\d+)/ -> { slug: $, parts: parts }
  else -> null
}) filter ($ != null)

fun getGithubHeaders() = dw::System::envVar("GITHUB_TOKEN") match {
  case GITHUB_TOKEN is String -> { Authorization: "Bearer $(GITHUB_TOKEN)" }
  else -> {}
}

var requests = issues map {
  slug: $.slug,
  response: GET(url`https://api.github.com/repos/$($.parts[1])/$($.parts[2])/issues/$($.parts[3])`, {
    headers: getGithubHeaders()
  })
}

fun getPending(lines: Array<String>) = lines filter ($ contains "- [ ]")
fun getFinished(lines: Array<String>) = lines filter ($ contains "- [x]")

fun getInfoFromIssueOrPr(issueOrPr) = do {
  var body = issueOrPr.response.body.body
  var lines = dw::core::Strings::lines(body)
  var empty = getPending(lines)
  var finished = getFinished(lines)
  var countEmpty = sizeOf(empty)
  var countFinished = sizeOf(finished)
  var countTotal = countEmpty+countFinished
  ---
  {
    slug:       issueOrPr.slug,
    link:       issueOrPr.response.body.html_url,
    title:      issueOrPr.response.body.title,
    body:       body,
    state:      issueOrPr.response.body.state,
    empty:      empty,
    finished:   finished,
    completion:
      if (issueOrPr.response.body.state == "closed") 100
      else if (countTotal == 0) 0
      else (countFinished/countTotal) * 100
  }
}

---
{
  issues: issues.*slug ,
  state: requests reduce (item, carry = {}) -> do {
    var value = getInfoFromIssueOrPr(item)
    ---
    { (carry), (value.slug): value }
  }
}