const AWS = require('aws-sdk')
// not all regions support ses
AWS.config.update({region: 'us-east-1'});
const IAM = new AWS.IAM()

exports.handler = async (event, context) => {

    var instances   =[]
    var users       =[]

    try {
        var params ={MaxItems:10}

        users   = await IAM.listUsers(params).promise()
        var user

        for (user of regions.Regions){
        
    
        }

        return true

    } catch (error) {

        console.log('error: ',error)
        return false

    }

}