import { readFile } from "fs/promises"

async function main() {
  const originalContent = (await readFile('roadmap.excalidraw.svg')).toString()
  console.log(originalContent)
}

main().catch((err) => {
  console.error(err)
  process.exitCode = 1
})
