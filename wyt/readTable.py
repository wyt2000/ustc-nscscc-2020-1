import sys
file = open('in.txt','r',encoding='UTF-8')
sys.stdout = open('out.txt','w+',encoding='UTF-8')

for line in file.readlines():
	str = line.split('|')
	for i in range(len(str)):
		str[i] = str[i].strip()
	f = str[1]
	t = str[2]
	width = str[3]
	output = '''
	register #(%s) MEM_WB_%s (
        .clk(clk),
        .rst(FlushW),
        .en(~StallW),
        .d(MEM.%s),
        .q(WB.%s)
	);'''% (str[3],str[2],str[1],str[2])
	print(output)



