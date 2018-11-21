#!/usr/bin/env perl

use strict;
use warnings;

use FindSeed ();

my @deals = ( <<'EOF' =~ /^ *([0-9]+)/gms );
 28099	4068
 11986	4101
 13996	4118
 31951	4134
 19124	4154
 16567	4160
  2696	4163
 18665	4185
 20729	4209
 30103	4211
 13466	4298
 17938	4299
  8425	4301
 17492	4333
 31694	4350
 22562	4354
 10788	4370
 16095	4393
 14450	4411
 14249	4477
 30615	4625
 12834	4626
 28762	4637
 11877	4650
 24166	4668
  2928	4668
 27201	4683
 25552	4684
 23278	4697
 30095	4699
  6240	4717
  6182	4774
 12344	4811
   237	4818
  4609	4863
   514	4870
 29931	4872
  1734	4876
  8127	4896
 17646	4899
 30055	4923
 12421	4924
 23424	4933
 30359	4956
   753	5035
 24341	5065
 28424	5115
  3467	5159
 24106	5176
  4808	5181
  4213	5275
 22040	5302
  5400	5313
   476	5314
   617	5359
 15513	5412
  4422	5432
 13583	5477
 26576	5484
 27046	5489
 19013	5508
 23547	5549
 30887	5562
 26557	5585
 20785	5671
 31119	5674
 31601	5677
 17323	5691
   327	5699
  9830	5702
 18320	5705
 14269	5743
 28920	5755
 19763	5759
  8613	5843
 29122	5854
 17356	5857
 12794	5912
 11433	5929
   178	5975
 25057	6023
 17985	6032
  1213	6036
 17247	6079
 18712	6126
 29734	6132
  2456	6136
  2081	6163
 17874	6209
 13867	6377
 17442	6428
 23420	6434
  3709	6479
  7518	6493
 24087	6590
  1136	6607
 26693	6635
 17115	6639
 28822	6645
 18872	6662
 26926	6768
  3342	7027
 17175	7143
  8436	7360
  9787	7560
  4236	7580
 11819	7605
  8454	7616
  5376	8218
 16768	9424
 13765	9868
  8858	11175
 13304	11228
  3717	11257
 25599	11627
  4267	13644
  3294	18707
  1941	20236
 10692	22789
 31465	23275
EOF

my @scans = (
    q#--method random-dfs -to "01[2345789]"#,
    q#--method random-dfs -to "01[234579]"#,
    q#--method random-dfs -to "01[234589]"#,
    q#--method random-dfs -to "01[234567]" -dto2 "6,0132[456789]"#,
    q#--method random-dfs -to "01[234567]" -dto2 "5,01[2345789]"#,
    q#--method random-dfs -to "[01][23457]"#,
    q#--method random-dfs -to "[0123457]"#,
    q#--method random-dfs -to "[01][23457]" -dto2 "4,[0123456][789]"#,
    q#--method random-dfs -to "[01][23457]" -dto2 "7,[0123][456789]"#,
    q#--method random-dfs -to "[01][23457]" -dto2 "7,[0123][4567]"#,
    q#--method random-dfs -to "[01][23457]" -dto2 "5,[0123][4567]"#,
    q#--method random-dfs -to "[01][23457]" -dto2 "10,[0123][4567]"#,
    q#--method random-dfs -to "[01][23457]" -dto2 "8,[0123][4567]"#,
q#--method random-dfs -to "01[234567]" -dto2 "5,01[2345789]" -dto2 "10,[0123][4567]"#,
);

FindSeed->parallel_find(
    {
        scan      => \@scans,
        deals     => \@deals,
        threshold => 50,
    },
);
