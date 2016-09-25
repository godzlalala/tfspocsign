            urp.login(username,userpw)
            pass
        if urp.isLoginPass() == False:
            return None
        
        urp.saveCookie()
        print('[Log in] successfully name:%s' % urp.getName())
        print('[note] %s' % urp.getNote())
        
        SigninTaskId = urp.getSigninTaskId()
        print('[SigninTaskId] %s' % SigninTaskId)

        jsonobj = urp.signin(SigninTaskId)
        print('[Sign in] %s' % jsonobj)
        os.system("pause") 
    except Exception as ex:
        print (ex)
        pass
        os.system("pause") 

if __name__ == '__main__':
    foo()

