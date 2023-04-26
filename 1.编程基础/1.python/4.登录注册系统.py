## just a case
## 单词拼写错误要务必注意
## 为什么设置判定状态要注意（可以从输入输出方面考虑）
## 整体框架与逻辑

def login():
    print('欢迎来到登录页面')
    print('-----------------')
    username = input('请输入用户名：')
    passwd = input('请输入密码：')
    #判定登录状态：
    login_state = False
    with open('./userdata.txt','r') as fp:
        user_data_list = fp.readlines()
        for user_data in user_data_list:
            usena = user_data.split('\t')[0]
            pw = user_data.split('\t')[1]
            if username == usena and passwd == pw:
                login_state = True
        if login_state == True:
            print('登录成功')
        else:
            print('登录失败')

def register():
    print('欢迎来到注册页面')
    print('-----------------')
    username = input('请输入用户名：')
    passwd = input('请输入密码：')
    re_passwd = input('请再次输入密码：')
    email = input('请输入你的邮箱：')
    
    
    # 判断用户名、密码是否是不合适的字符
    # 判断用户名状态
    #判断密码状态
    if passwd == re_passwd:
        isHave = False #用户名是否重复的状态
        with open('./userdata.txt','r+') as fp:
            # 读取文件中所有注册的用户名
            user_data_list = fp.readlines()
            for user_data in user_data_list:
                userName = user_data.split('\t')[0]
                if username == userName:
                    isHave = True
            if isHave == False:
                fp.write(username+'\t'+passwd+'\t'+email+'\n')
                print('注册成功')
            else:
                print(f'注册失败，{username}用户名已被占用！！')
    else:
        print('两次密码不同，注册失败！')

def main():
    print('欢迎来到XXX管理系统')
    print('-------------------')
    print('1.登录\n2.注册\n3.退出')
    choose = int(input("请选择你的需求"))
    if choose == 1:
        login()
    elif choose == 2:
        register()
    elif choose == 3:
        exit()
    else:
        print('输入有误，程序退出！')

if __name__ == "__main__":
    main()