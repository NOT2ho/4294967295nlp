import fs from 'fs'
import { nGram } from "simplengrams";
export default function markovCreate() {
    fs.readFile('./corpus/pure_4294967295.txt', (err, data) => {
        if (err) {
            console.error(err);
            return;
        }
        const text = data.toString();

        
        axios
            .post( 
                "http://aiopen.etri.re.kr:8000/WiseNLU_spoken",
                {
                    argument: {
                        analysis_code: "morp", 
                        text: text,
                    },
                },
                {
                    headers: {
                        
                        Authorization: '36cdb264-5d2e-40eb-a067-439b7647fe18',
                    },
                }
            )
            .then((res) => {
                const sentenceArray = res.data.return_object.sentence
                const resultArr = sentenceArray.map((e) => e.morp);
                fs.writeFile('./corpus/morp.txt', JSON.stringify(resultArr), (err) => {
                    if (err) console.log('Error: ', err);
                    else console.log('File created');
                },
                )
      
           
            }
            )
        fs.readFile('./file/morp.txt', (err, data) => {
            if (err)
                console.error(err);
                                
            const genSentence = (cfd, landkey, num) => {
                let sentence = ['']
                
                let word = cfd[landkey][0]
                for (let i = 0; i < num; i++) {
                    sentence.push(word)
                    word = cfd[word][Math.floor(Math.random() * cfd[word].length)]

                }
                //const regEx = /'^J|^E|^X|^S'/
                let res = sentence.join(' ')
                return res
            }
   
            const calc_cfd = () => {
                let cfd = new Object;
                const words = JSON.parse(data.toString())
                let sentences = [[]]
                let ngrams = []
                for (let s in words) {
                    for (let i in words[s]) {
                        sentences.push(words[s][i]['lemma'])
                    
                
                        let sentence = sentences.join(' ')
                        ngrams = nGram(sentence);
                       
                    }
                }
                const landkey = ngrams[Math.floor(Math.random() * ngrams.length)][0]
                for (let arrs in ngrams) {
                    let arr = ngrams[arrs]
                    let w1 = arr[0]
                    let w2 = arr[1]
                    Object.assign(cfd, { [w1]: [] })
                    for (let arrs2 in ngrams) {
                        let arr = ngrams[arrs2]
                        let p1 = arr[0]
                        let p2 = arr[1]
                        
                        if (w1 == p1)
                            cfd[w1].push(p2)
                        
                    }
                 
                }
                    
                return [cfd, landkey]
            }
            const max = 500
            const min = 50
            let res = genSentence(calc_cfd()[0], calc_cfd()[1], Math.floor(Math.random() * (max - min) + min))
            console.log(res)
        })
    }
    )
}