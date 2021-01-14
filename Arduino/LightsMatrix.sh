#!/bin/bash
# Generate 4 row 8 column matrix to match LED colors.

array=('Functions' 'Vol_Up' 'Mute' 'Vol_Down')

# Table start
echo "<table>"
for i in "${!array[@]}"
do
  # Convert 0 to F, 1 to B, 2 to 7, 3 to 3
  # i.e. x to 15-x
  foreground=$(echo "obase=16; ibase=10; 1 + 2*$i"|bc)
  background=$(echo "obase=16; ibase=16; 10 - $foreground"|bc)
  colorArray=($background $foreground)
  # Current row header
  echo "<tr>"
  # First column
  curBin="111"
  curColor=""
  for (( colorI=0; colorI<${#curBin}; colorI++ )); do
    # Repeat current color two times
    curColor+="${colorArray[${curBin:$colorI:1}]}"
    curColor+="${colorArray[${curBin:$colorI:1}]}"
  done
  echo "<td bgcolor=#$curColor>$curColor <br> ${array[$i]}</td>"
  # Other column
  for num in {6..0}
  do
    curBin=$(printf "%03d" $(echo "obase=2; ibase=10; $num"|bc ))
    curColor=""
    for (( colorI=0; colorI<${#curBin}; colorI++ )); do
        # Repeat current color two times
        curColor+="${colorArray[${curBin:$colorI:1}]}"
        curColor+="${colorArray[${curBin:$colorI:1}]}"
    done
    echo "<td bgcolor=#$curColor>$curColor</td>"
  done
  
  # End current row
  echo "</tr>"
done

# End table
echo "</table>"