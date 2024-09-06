import fs from 'fs'
import path from 'path';


class Node {
    child: Map<string, Node>;
    output: string[][]
    fail: null | Node
    end : boolean
    
    constructor() {
        this.child = new Map()
        this.output = []
        this.fail = null
        this.end = false
    }
}

class AhoCorasick {
    root: Node
    constructor() {
        this.root = new Node();
    }

    insert(words: string[]) {
        let output = words
        let word = words[0]
        let node = this.root;
        for (const char of word) {
            if (!node.child.get(char))
                node.child.set(char, new Node());
            node = node.child.get(char) || this.root;
        }
        node.output.push(output);
        node.end = true
    }


    fail() {
        const que : Node[] = []
        for (const [i, c] of this.root.child.entries()) {
            c.fail = this.root;
            que.push(c);
          
            while (que.length > 0) {
                const currentNode = que.shift();
                if (typeof currentNode === undefined)
                    break;
                            
                for (const i in currentNode?.child) {
                    const nextNode = currentNode?.child.get(i);

                    if (nextNode == null)
                        continue;
                
                    que.push(nextNode);    
                    let failNode = currentNode.fail;

                    while (failNode !== null && !failNode.child.get(i)) {
                        failNode = failNode.fail;
                    }
                
                    if (currentNode != this.root)
                        nextNode.fail = failNode ? failNode.child.get(i) || this.root : this.root;

                    if (nextNode.fail !== null)
                        nextNode.output = nextNode.output.concat(nextNode.fail.output);
                }
        
            }
        }
    }

    search(input: string) : Map<number, string[][]> {
        this.fail();
        let text = input;
        let result : Map<number, string[][]> = new Map();
        let currentNode : Node | null = this.root;
        for (let i = 0; i < text.length; i++) {
            const char = text[i];

            while (currentNode !== null && !currentNode.child.get(char)) {
                   currentNode = currentNode.fail;
            }
    
            currentNode = currentNode ? currentNode.child.get(char) || this.root : this.root;
        
            for (const output of currentNode.output) {
                let resultArray = result.get(i - output[0].length + 1) || [];
                resultArray.push(output);
                result.set(i - output[0].length + 1, resultArray);
            }   
        }
        return result;
    }

}

class Pos {
    preprocess = (text: string) => {
        const str = text.replace(/([^가-힣a-zA-Z]*)/, " ")
        const undefArr = str.split(' ')
        const arr = undefArr.splice(1, undefArr.length)
        return arr.toString();
    }

    tag = (text: string) => {
        const ac = new AhoCorasick();
        let res : Map<number, string[][]> = new Map();
        try {
            const notpos = new RegExp(/^(?:.*[\\\/])?notpos_kr(?:[\\\/]*)$/);
       
            
            const rec = (filepath: string) => {
                if (notpos.test(filepath) || filepath == process.cwd())
                     return (path.join(filepath, 'dic/dic.csv'))
                return rec(path.join(filepath, '..'))
            }
            
            const data = fs.readFileSync(rec(__dirname))
            const pd = data.toString().split('\n');

            for (let i of pd) {
                let word = i.slice(0, -1).split(',');
                ac.insert(word);
            }
            res = ac.search(text);

            const result : Map<number, string[]> = new Map();
            for (let [i, x] of res.entries()) {
                const resultArray = x[x.length - 1] || [];
                result.set(i, resultArray);
            }
       
            let idx = 0
            let key = 0
            let ret : Map<number, string[]> = new Map();
            let keys = Array.from(result.keys());
            for (let s of text)
            {
                if (idx >= text.length) break;
                key = keys[idx];
                const resv = result.get(idx) || []
                if (resv.length == 0) {
                    if (text[idx] != ' ') {
                        ret.set(idx, [text[idx], 'UNK']);
                    }
                    idx++;
                } else {
                    ret.set(idx, resv);
                    idx += resv[0].length;
                }
            }
                
            return Array.from(ret.values());
        } catch (err) {
            console.error(err);
        }
    }
}

export {Pos}