import { readFile } from "fs/promises"

async function main() {}

main().catch((err) => {
  console.error(err)
  process.exitCode = 1
})
