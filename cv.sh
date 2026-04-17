swift run CVGenerator --templates ./Templates/NavyHeader    --input resume-iOS-staff.json  --output resume-iOS-staff-navy.html    --pdf
swift run CVGenerator --templates ./Templates/NavyHeader    --input resume-iOS-senior.json --output resume-iOS-senior-navy.html   --pdf
swift run CVGenerator --templates ./Templates/ForestSidebar --input resume-iOS-staff.json  --output resume-iOS-staff-forest.html  --pdf
swift run CVGenerator --templates ./Templates/ForestSidebar --input resume-iOS-senior.json --output resume-iOS-senior-forest.html --pdf
swift run CVGenerator --templates ./Templates/SlateAmber    --input resume-iOS-staff.json  --output resume-iOS-staff-amber.html   --pdf
swift run CVGenerator --templates ./Templates/SlateAmber    --input resume-iOS-senior.json --output resume-iOS-senior-amber.html  --pdf
swift run CVGenerator --templates ./Templates/Asphalt       --input resume-iOS-staff.json  --output resume-iOS-staff-asphalt.html --pdf
swift run CVGenerator --templates ./Templates/Asphalt       --input resume-iOS-senior.json --output resume-iOS-senior-asphalt.html --pdf
rm resume-iOS-staff-navy.html resume-iOS-senior-navy.html
rm resume-iOS-staff-forest.html resume-iOS-senior-forest.html
rm resume-iOS-staff-amber.html resume-iOS-senior-amber.html
rm resume-iOS-staff-asphalt.html resume-iOS-senior-asphalt.html
