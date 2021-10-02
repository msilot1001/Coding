register = "990101-1234567"
gender = "none";

if(len(register) == 14):
    print("성별 : " + register[7])
    print("생년월일 : " + register[:6])
    print("등록번호 : " + register[7:])