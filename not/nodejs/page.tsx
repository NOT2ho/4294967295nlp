'use server'
import { promises as fs } from 'fs'
import { nGram } from "simplengrams";
import pool from "../lib/db";
import path from 'path'


import { redirect } from 'next/navigation'
export default async function markovCreate() {
    try {
        await fs.readFile('/tmp/tmp.txt')
    } catch (err) {
        await fs.writeFile('/tmp/tmp.txt', "")
    }
        const datas = await fs.readFile('/tmp/tmp.txt');
        const text = datas.toString();
        //console.log("text: " + text)

        const data = await pos(text) ?? ''
        
        async function genSentence(cfd, landkey, num) {
                let sentence = ['']
            let word = await cfd[await landkey][0]
                for (let i = 0; i < num; i++) {
                    sentence.push(word)
                //    //console.log(cfd)
                    //console.log(word)
                    if (cfd[word]) 
                        word = cfd[word][Math.floor(Math.random() * (cfd[word].length))]
                    else
                        continue
            }

            
                //const regEx = /'^J|^E|^X|^S'/
                let res = sentence.join(' ')
                return res
            }
            ////console.log(data)
   
            async function calc_cfd() {
                let cfd = {};
                const words : any = data
                let sentences = [[]]
                let ngrams: (string | null)[][] = []

                for (let s in words) {
                            
                        sentences.push(words[s][0])
                        //    //console.log(words[s][0])
                
                    
                    }
                
                
                                let sentence = sentences.join(' ')
                        ngrams = nGram(sentence);
                for (let arrs in ngrams) {
                    let arr = ngrams[arrs]
                    ////console.log(arr)
                    if (arr[0] == null) {
                        throw "ngram issue"
                    }
                    let w1: string = arr[0]
                    Object.assign(cfd, { [w1]: [] })
                    for (let arrs2 in ngrams) {
                        let arr = ngrams[arrs2]
                        let p1 = arr[0]
                        let p2 = arr[1]
                        
                        if (w1 == p1)
                            cfd[w1].push(p2)
                        ////console.log('들어감')
                    }
                  
                }
              //console.log(ngrams)
                const landkey = ngrams[Math.floor(Math.random() * ngrams.length)][0]
               
                return [cfd, landkey]
                
            }
                       const max = 500
            const min = 50
            let res = await genSentence((await calc_cfd())[0], (await calc_cfd())[1], Math.floor(Math.random() * (max - min) + min))
           console.log(res)
        
            const insert = async () => {
                try {
                    const sql = 'INSERT INTO markov (body) VALUES ("?")';
                    const result = await pool.query(sql, [res]);
                    //console.log(result);
                } catch (err) {
                    //console.log(err);
                }
            }

            await insert();
             redirect('/markovResult')
        }

        /*
        fs.readFile('/tmp/tmp.txt', (err, data) => {
            if (err) {
                console.error(err);
                return;
            }
            
        })*/
    
    
    async function pos(text) {
         console.log("실행됨")
        const str_ = text.replace(/[^가-힣a-zA-Z\n ]*/g, "")
        const str = str_.replace(/\n+/g, " ")
       // //console.log('정규식이 왜 안 되지: ' + str)
        const undefArr = str.split(' ')
        const arr = await undefArr.splice(1, undefArr.length)
        // //console.log(arr)
        let word = 'n'
        let tag = ''
        let res: string[][] = []
        let regex = /nothing/
    
        async function csvRead(csv) {
            let csvs = csv.toString().split('\n')
            return csvs
        }
        async function ifN() {
            try {
                const data = await fs.readFile(path.join(process.cwd() + '/dic.csv'))
                let pd = await csvRead(data)
                for (let j in arr) {
                    for (let i in pd) {
                        word = pd[i].split(',')[0]
                        tag = pd[i].split(',')[1].slice(0, -2)
                        regex = new RegExp(`^(${word})`);
               
                        if (regex.test(arr[j]) === true) {
                            res.push([word, tag])
                            console.log("POS analyzed")
                            if (word.length != arr[j].length)
                                res.push([arr[j].slice(word.length, arr[j].length), 'J|X'])
                            pd = pd.splice(1, pd.length)
                                   
                        }

                    }
                } return res
            }
            catch (err) {
                console.error(err)
            }
        }
        return (ifN())
       
        //   redirect('/markovResult')
    }

