utils   = require('../utils/index')
{mocks, i18n} = utils
errorResponseMock = mocks.api.errorResponse

describe "ErrorResponse", (done)->


  beforeEach ->
    app.config.environment = "test"

    class @CustomSerializableError extends  SerializableError
      constructor: (@data)->

      toJSON: ->
        @data

    class @UnknownError
      constructor: (@message)->
      toJSON: ->
        {message: @message}

  describe "class constructor shall be able to accept ", ->
    it "[ERP-0001] String as parameter", ->
      errorString = "follow the white rabbit"
      resp        = new Responses::ErrorJson errorString
      respMock    = errorResponseMock.factory().addString(errorString)
      expect(resp.toJSON()).to.deep.equal(respMock.get())



    it "[ERP-0002] Error as parameter", ->
      errorString = "Winter is close"
      resp        = new Responses::ErrorJson new Error errorString
      respMock    = errorResponseMock.factory().addException(errorString)
      expect(resp.toJSON()).to.deep.equal(respMock.get())

    it "[ERP-0002] class derived from Error as parameter (TypeError)", ->
      errorString = "I'm the mother of dragons!"
      resp        = new Responses::ErrorJson new TypeError errorString
      respMock    = errorResponseMock.factory().addException(errorString)
      expect(resp.toJSON()).to.deep.equal(respMock.get())

    it "[ERP-0002] class derived from Error as parameter (custom error class)", ->
      class CustomError extends Error

      errorString = "Gigiti gigity goooo"
      resp        = new Responses::ErrorJson new CustomError errorString
      respMock    = errorResponseMock.factory().addException(errorString)
      expect(resp.toJSON()).to.deep.equal(respMock.get())

    it "[ERP-0002] Error as parameter and add nothing to the errors array in production mode", ->
      app.config.environment = "production"

      errorString = "Screw you guys I'm going home"
      resp        = new Responses::ErrorJson new Error errorString
      #mock with no errors
      respMock    = errorResponseMock.factory()
      expect(resp.toJSON()).to.deep.equal(respMock.get())


    it "[ERP-0002] Error as parameter and doesn't add its data to the errors array in production mode", ->
      app.config.environment = "production"

      stringErrorText         = "Bender V. Rodrigez"
      errorClassText          = "Fry N."
      serializableErrorText   = "As died as a dodod"

      errorData =
        errorType: 'customErrorType'
        messages: [serializableErrorText]

      resp        = new Responses::ErrorJson [stringErrorText, new Error(errorClassText), new @CustomSerializableError(errorData)]
      #mock with no errors
      respMock    = errorResponseMock.factory().addString(stringErrorText).addCustom(errorData)
      expect(resp.toJSON()).to.deep.equal(respMock.get())



    it "[ERP-0003] Instance of any class derived from SerializableError class as parameter", ->
      errorString = "Scooby dooby dooo"
      errorData =
        errorType: 'customErrorType'
        messages: [errorString]

      resp        = new Responses::ErrorJson new @CustomSerializableError(errorData)
      respMock    = errorResponseMock.factory().addCustom(errorData)
      expect(resp.toJSON()).to.deep.equal(respMock.get())



    it "[ERP-0004] accept array of combinations of all error classes listed in reqs as parameter", ->
      # string messages for each error type
      stringErrorText         = "Bender Rodrigez"
      errorClassText          = "Fry"
      serializableErrorText   = "Lila"

      # define class derived from SerializableError
      errorData =
        errorType: 'customErrorType'
        messages: [serializableErrorText]


      respMock    = errorResponseMock.factory().addString(stringErrorText).addException(errorClassText).addCustom(errorData)
      resp        = new Responses::ErrorJson [stringErrorText, new Error(errorClassText), new @CustomSerializableError(errorData)]
      expect(resp.toJSON()).to.deep.equal(respMock.get())



    describe "class constructor shall add nothing to the errors array", ->
      it "[ERP-0005]  if type of argument passed to the constructor, differs from  listed in requirements (1)", ->
        errorString = "follow the white rabbit"


        resp        = new Responses::ErrorJson new @UnknownError(errorString)
        respMock    = errorResponseMock.factory()
        expect(resp.toJSON()).to.deep.equal(respMock.get())

      it "[ERP-0005]  if type of argument passed to the constructor, differs from  listed in requirements (2)", ->
        # string messages for each error type
        stringErrorText         = "Bender S. Rodrigez"
        errorClassText          = "Fry D."
        unknownErrorText        = "follow the white rabbit-*"
        serializableErrorText   = "E. Lila#"

        errorData =
          errorType: 'customErrorType'
          messages: [serializableErrorText]


        console.log @UnknownError
        resp        = new Responses::ErrorJson [stringErrorText, new @UnknownError(unknownErrorText), new Error(errorClassText),
                                         new @CustomSerializableError(errorData) ]
        respMock    = errorResponseMock.factory().addString(stringErrorText).addException(errorClassText).addCustom(errorData)
        expect(resp.toJSON()).to.deep.equal(respMock.get())



