# knapsack

ナップサック問題を解くためのプログラム。

## 使用法

``` sh
$ ./knapsack.pl --help
usage: ./knapsack.pl [options] MAX_WEIGHT[:MAX_WEIGHT:...] FILE[S...]
options:
  -c, --cofficient  value (3つ目の値) を係数で指定する。
  -v, --verbose     詳細な情報を出力する。
  -h, --help        このメッセージを表示する。

args:
  MAX_WEIGHT[:MAX_WEIGHT:...]   ナップサックの最大容量。`:` 区切りで複数個分指定できる。
```

## 使用例

``` sh
# ナップサックに入れる候補のリストファイルを用意しておく。
# タブ区切り形式で、各列の内容は次の通り。
# 1列目: 名前
# 2列目: 重さ
# 3列目: 価値 (オプション。省略した場合は「重さ」の値を「価値」として使用する)
# なお、`#` で始まる行はコメント行とみなす。
# ※ファイル名やファイルの内容に特に意味はない。
$ cat items.tsv
# name	weight	value
item1	3432	6864
item2	4008	8016
item3	459	459
item4	660	660
item5	459	459
item6	726	726
item7	528	528
item8	3168	3168
item9	693	693

# ナップサックに入れるものの価値が最大になる組み合わせを出力する。
# このとき、ナップサックにはweight 5000まで入れられるように (引数で) 指定している。
# 出力結果では、最初の列にナップサックの番号を出力する。
# この場合、
# - ナップサック1: weight: 4995 (4008 + 459 + 528), value: 9003 (8016 + 459 + 528)
# - ナップサック2: weight: 4851 (3432 + 726 + 693), value: 8283 (6864 + 726 + 693)
# - ナップサック3: weight: 4287 (660 + 459 + 3168), value: 4287 (660 + 459 + 3168)
# という結果となっている。
❯ cat items.tsv | ./knapsack.pl 5000
1	item2	4008	8016
1	item3	459	459
1	item7	528	528
2	item1	3432	6864
2	item6	726	726
2	item9	693	693
3	item4	660	660
3	item5	459	459
3	item8	3168	3168

# (リストファイルの「価値」は省略した場合「重さ」が価値として使用されるが)
# 「価値」を指定する代わりに「重さ」に対する「係数」を指定することもできる。
# 係数で指定する場合、上記の `items.tsv` と同じ意味合いの入力となるファイルは次のようになる。
$ cat items-c.tsv
# name	weight	cofficient
item1	3432	2
item2	4008	2
item3	459	1
item4	660	1
item5	459	1
item6	726	1
item7	528	1
item8	3168	1
item9	693	1

# `--cofficient` (または `-c`) オプションを指定して実行すれば入力の3列目を「重さに対する係数」として処理する。
# 「`--cofficient` オプションを指定せずに「価値」を指定した場合」と同じ出力が得られる。
$ cat items-c.tsv | ./knapsack.pl --cofficient 5000
1	item2	4008	2
1	item3	459	1
1	item7	528	1
2	item1	3432	2
2	item6	726	1
2	item9	693	1
3	item4	660	1
3	item5	459	1
3	item8	3168	1

# ナップサックの最大容量は複数個分指定できる。
# 1つめのナップサックの最大容量を4600, 2つめを4100, それ以降を5000とするには次のように指定する。
$ cat items-c.tsv | ./knapsack.pl --cofficient 4600:4100:5000
1       item2   4008    2
1       item7   528     1
2       item1   3432    2
2       item4   660     1
3       item3   459     1
3       item5   459     1
3       item6   726     1
3       item8   3168    1
4       item9   693     1
```


## 参考

[動的計画法（ナップサック問題） - アルゴリズム講習会](https://dai1741.github.io/maximum-algo-2012/docs/dynamic-programming/)
