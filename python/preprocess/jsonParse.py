import json

def jsonParse(num):
    path = 'C:/4294967295nlp/corpus/private/TL_out'

    for i in range(num):
        try:
            file = open(path + '/' + str(i).zfill(4) + '.json', 'rt', encoding='UTF8').read()
            data = json.loads(file)
            extracted = data['list'][0]['list'][0]['audio'][0]['text']
            print(extracted)

        except:
           ...