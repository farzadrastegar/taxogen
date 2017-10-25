from ..tweet_preprocessing.tweet_handler import preprocess_tweet
from ..tweet_preprocessing.util.logger import Logger
from ..tweet_preprocessing.paras import load_la_tweets_paras
import subprocess

class LINE:
    def __init__(self, paras, logger):
        self.input = paras['pure_tweets']
        self.train = paras['train']
        self.output = paras['embeddings']
        self.size = paras['size']
        self.order = paras['order']
        self.negative = paras['negative']
        self.samples = paras['samples']
        self.rho = paras['rho']
        self.threads = paras['thread']
        self.logger = logger

    def build_train_file(self):

        self.logger(Logger.build_log_message(self.__class__.__name__, self.build_train_file.__name__,
                                             'Start building training file'))

        with open(self.input, 'r') as f:
            data = f.readlines()

        word_co_occurrence = {}

        count = 0
        for line in data:
            line = preprocess_tweet(line, lower=True)
            line = line.split(' ')

            for i in range(len(line)):
                for j in range(i+1, len(line)):
                    co_w1 = '{}\t{}'.format(line[i], line[j])
                    co_w2 = '{}\t{}'.format(line[j], line[i])

                    if co_w1 not in word_co_occurrence:
                        word_co_occurrence[co_w1] = 0
                    if co_w2 not in word_co_occurrence:
                        word_co_occurrence[co_w2] = 0

                    word_co_occurrence[co_w1] += 1
                    word_co_occurrence[co_w2] += 1

            count += 1

            if count % 10000 == 0:
                self.logger(Logger.build_log_message(self.__class__.__name__, self.build_train_file.__name__, '{} lines processed'.format(count)))

        res_list = []
        for key, val in word_co_occurrence.iteritems():
            res_list.append('{}\t{}'.format(key, val))

        with open(self.train, 'wb') as outf:
            outf.write('\n'.join(res_list))

    def run(self):
        return


if __name__ == '__main__':
    git_version = subprocess.Popen('git rev-parse --short HEAD', shell=True, stdout=subprocess.PIPE).communicate()[0].strip('\n')

    paras = load_la_tweets_paras(dir=git_version)
    logger = Logger(paras['log'])
    line =LINE(paras)
    line.build_train_file()
