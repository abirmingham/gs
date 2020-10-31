#!/usr/bin/env node

const readline = require("readline");
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false,
});

let items = [];
let item = null;

rl.on("line", (line) => {
    if (line.match(/^an? /)) {
        item = {
            name: line,
            bonuses: [],
            crumbly: false,
        };
    }
    else if (line.match(/^Enhancive bonus: /)) {
        item.bonuses.push(line.slice('Enhancive bonus: '.length).replace('Level ', '').replace(' required', ''))
    }
    else if (line.match(/^Crumbly on enhancive: Yes/)) {
        item.crumbly = true
    }
    else if (line.match(/^Wearable location: /)) {
        item.location = line.slice('Wearable location: '.length)
        items.push(item)
    }
});

rl.on("close", () => {
  items.forEach(item => {
      console.log([item.location == 'anywhere' ? 'pin' : item.location, item.name, item.crumbly ? 't' : 'f', item.bonuses.join(' ')].join(', '))
  });
});
