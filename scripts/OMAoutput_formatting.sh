for i in $(awk -F '_' '{print $2}' $1 | awk -F " " '{print $2}' | uniq); do GO=$(grep $i $1 | awk -F " " '{print $4}' | sed -z '$ s/\n$//g' | sort -u | sed "s/  /,/g "); echo -e $i"\t"$GO | sed 's/ /,/g' >> part_1b/OMA/OMA_formatted.txt; done
