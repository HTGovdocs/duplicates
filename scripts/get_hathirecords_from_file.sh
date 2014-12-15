cat /htapps/mwarin.babel/gdweb_script/data/hathi_full_20140801.txt |
egrep $'^[^\t]+\t[^\t]+\t[^\t]+\t(000002397|000033778|000377052|000496697|000559036|000877728|001044389|001046607|001120647|001142818|001174824|001257028|001312688|001312688|001508284|001515451|001516585|001551808|001558403|001564048|001568688|001575096|001587013|001590030|001623475|001719662|001749241|001885971|002009623|002028803|002061570|002140870|002429309|002747844|002747844|002747880|002778584|002868327|002874324|003205903|003214642|003477201|003478950|003596103|003910103|003933162|003938993|003963524|004378610|004421158|004509570|005504567|005872184|005951231|005951270|005979103|005979162|005979188|005980743|005982101|005982201|005982952|006230065|006260653|006298801|006585491|007054239|007055192|007055565|007055586|007055595|007055598|007055623|007055629|007055645|007055649|007055654|007150535|007169181|007395695|007403230|007426629|007833458|008511739|008523400|008606992|008888182|009026822|009032369|009124504|009220688|009260659|009572430|009585881|009585998|009602522|009610998|009790704|009792281|010057903|010067635|010078750|010153667)\t' |
awk -F'\t' '{a[$4] = $0} END{for (i in a) {print a[i]}}' > /htapps/mwarin.babel/gdweb_script/data/hathi_dup_set.tsv