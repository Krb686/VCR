import serial
from array import *
import plotly.plotly as py
from plotly.graph_objs import *


#This value adjusts how many samples will be created in the VHDL ROM
SAMPLE_MAX = 32768 * 6

dataType = "unsigned"


ser = serial.Serial(12, 781250)

ser.flush()
ser.flushInput()
ser.flushOutput()

xArray = array('l')
yArray = array('l')
sqArray = array('l')
charArray = array('c')

data = 0
lowByte = 0
highBye = 0
total = 0
count = 0


while(True):
	
	#Read the first byte
	byte = ser.read()
	
	charArray.append(byte)
	count +=1
	
	if(count == SAMPLE_MAX):
		break
		

"""
	
	#Convert to binary representation
	byte1_bin = ord(byte1)
	
	#If the pad byte is detected.  Could be triggered on the 1st, 3rd, or 5th pad bytes
	if(byte1_bin == 255):
		
		#Read the 2nd byte
		byte2 = ser.read()
		
		#Convert to binary representation
		byte2_bin = ord(byte2)
		
		#Check if the top bit is a 1.  This eliminates the 2nd byte as a candidate.  Only the 1st byte or checksum remain as possibilities.
		if((byte2_bin & 128) == 128):
		
			#Read the 3rd byte
			byte3 = ser.read()
			
			#Convert to binary representation
			byte3_bin = ord(byte3)
			
			#Check if byte 3 is another pad byte. At this point, the data may be synchronized, or it may have read pad byte 3, checksum, pad byte 1 of next transmission.
			if(byte3_bin == 255):
			
				#Read the 4th byte
				byte4 = ser.read()
				
				#Convert to binary representation
				byte4_bin = ord(byte4)
			
				#Check if the top bit is a 0. Now, the data should be in sync.  This must be the 2nd data byte, because if it were wrapping around, this would be 
				# data byte 1, and would have a high upper bit
				if((byte4_bin & 128) == 0):
			
					#Read the 5th byte
					byte5 = ser.read()
					
					#Convert
					byte5_bin = ord(byte5)
					
					#Check for the 3rd pad byte
					if(byte5_bin == 255):
						
						#Read the checksum byte
						byte6 = ser.read()
						
						byte6_bin = ord(byte6)
						
						checksum_calc 
						
						if(checksum_calc == byte6_bin):
							#print("Checksum is good!")
							
							

							

							
							
				
							
							
				
							
							
							
							
							if(count == SAMPLE_MAX):
								break
	
"""	
	
	
	

ser.close()

i = 0
count = 0
while(i < SAMPLE_MAX - 5):
	byte1 = charArray[i]
	byte2 = charArray[i+1]
	byte3 = charArray[i+2]
	byte4 = charArray[i+3]
	byte5 = charArray[i+4]
	byte6 = charArray[i+5]
	
	byte1_bin = ord(byte1)
	byte2_bin = ord(byte2)
	byte3_bin = ord(byte3)
	byte4_bin = ord(byte4)
	byte5_bin = ord(byte5)
	byte6_bin = ord(byte6)
	
	byte2_tag = byte2_bin & 192
	byte4_tag = byte4_bin & 192
	byte6_tag = byte6_bin & 192
	
	byte_data_sum = (byte2_bin & 15) + ((byte2_bin & 48) / 16) + ((byte4_bin & 3) * 4) + ((byte4_bin & 60) / 4)
	checksum = byte6_bin & 63
	
	
	
	if (byte1_bin == 255 and byte2_tag == 0 and byte3_bin == 255 and byte4_tag == 64 and byte5_bin == 255 and byte6_tag == 128 and byte_data_sum == checksum):
		count+=1
		print(".\n")
		lowByte  = byte2_bin & 63
		highByte = byte4_bin & 63
		
		if(dataType == "unsigned"):
			total = lowByte + (highByte * 64)
		elif(dataType == "signed"):
			if((highByte & 32) == 32):
				total = lowByte + (highByte * 64) - 4096
			elif((highByte & 32) == 0):
				total = lowByte + (highByte * 64)
				
		totalsq = total * total
		
		yArray.append(total)
		sqArray.append(totalsq)
		
		xArray.append(count)
		
		i+=6
	else:
		print("BAD\n")
		i+=1
		
serialFile = open("serialFile", "w")

for i in range(0, SAMPLE_MAX):
	byte_bin = ord(charArray[i])
	
	if(i%6 == 0):
		serialFile.write("\n\t\t\t")
	serialFile.write(str(byte_bin) + " ")
	yArray.append(byte_bin)
	
serialFile.close()

## Write the output data to a file in VHDL ROM format
outputFile = open("outputfile", "w")

#outputFile.write("\tconstant DATA_ROM : ROM := (\n")


print25 = 0
print50 = 0
print75 = 0

for i in range(0, SAMPLE_MAX):
	decValue = format(yArray[i], "d")
	
	if(i % 16 == 0):
		outputFile.write("\t\t\t")
		
	if(i < SAMPLE_MAX-1):
		outputFile.write("" + decValue + " ")
	else:
		outputFile.write("" + decValue + "")
		
	if((i+1) % 16 == 0):
		outputFile.write("\n")

outputFile.write("\t\t\t)")
outputFile.close()

"""
for i in range(0, SAMPLE_MAX):

	hexValue = format(yArray[i], "x")
	
	if(i % 16 == 0):
		outputFile.write("\t\t\t")
		
	if(i < SAMPLE_MAX-1):
		outputFile.write("x\"" + hexValue + "\", ")
	else:
		outputFile.write("x\"" + hexValue + "\"")
	
	if((i+1) % 16 == 0):
		outputFile.write("\n")
		
	if(((i / float(SAMPLE_MAX)) > 0.25) and (print25 == 0)):
		print("25%")
		print25 = 1
	elif(((i / float(SAMPLE_MAX)) > 0.50) and (print50 == 0)):
		print("50%")
		print50 = 1
	elif((i / float(SAMPLE_MAX) > 0.75) and (print75 == 0)):
		print("75%")
		print75 = 1
	elif(i == SAMPLE_MAX - 1):
		print("100%")
outputFile.write("\t\t\t);")
outputFile.close()
"""

##Create a plot.ly graph
trace1 = Scatter(
    x=xArray,
    y=yArray
)

data = Data([trace1])
plot_url = py.plot(data, filename='basic-line')


