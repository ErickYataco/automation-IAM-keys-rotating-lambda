const AWS = require('aws-sdk')
// not all regions support ses
AWS.config.update({region: 'us-east-1'});
const IAM = new AWS.IAM()

exports.handler = async (event, context) => {

    try {
        let params={MaxItems:1}, isLastUser = false, users=[],user, keys=[],key, age,timeDiff

        while (!isLastUser){
            users   = await IAM.listUsers(params).promise()
            for (user of users.Users){
                keys = await IAM.listAccessKeys({UserName:user.UserName}).promise()
                for (key of keys.AccessKeyMetadata){
                    
                    timeDiff = (new Date()) - (new Date(key.CreateDate));
                    age      = timeDiff / (1000 * 60 * 60 * 24)>>0 
                    if (age > process.env.MAX_AGE){
                        console.log('key '+key.AccessKeyId+' for user '+user.UserName+'is expired '+age+' days')
                        await IAM.updateAccessKey({
                            AccessKeyId: key.AccessKeyId, 
                            Status:      "Inactive", 
                            UserName:    user.UserName
                        }).promise()
                    }
                }
            }
            if (users.IsTruncated){
                isLastUser= false
                params.Marker =  users.Marker   
            }else{
                isLastUser = true
            }
        }

        return true

    } catch (error) {

        console.log('error: ',error)
        return false

    }

}