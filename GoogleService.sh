echo ${SRCROOT} > aa.txt
if [ -e ${SRCROOT}/ChatUI/GoogleService-Info.plist ]; then
	rm ${SRCROOT}/ChatUI/GoogleService-Info.plist
fi
cp ${SRCROOT}/ChatUI/GoogleService/GoogleService-Info-prod.plist ${SRCROOT}/ChatUI/GoogleService-Info.plist
