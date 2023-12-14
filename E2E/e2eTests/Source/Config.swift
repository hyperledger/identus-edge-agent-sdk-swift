import Foundation

/// Initializes CucumberLite configuration
class Config: TestFramework {
    static var mediatorOobUrl: String = ""
    static var agentUrl: String = ""
    static var publishedDid: String = ""
    static var jwtSchemaGuid: String = ""
    static var anoncredDefinitionGuid: String = ""
    static var apiKey: String = ""
    
    static var shared: Config?
    
    override class func createInstance() -> TestFrameworkProtocol {
        let instance = Config()
        self.instance = instance
        return instance
    }
    
    override class func createActors() async throws -> [String : Actor]  {
        var actors: [String: Actor] = [:]
        actors["Cloud Agent"] = Actor("Cloud Agent").whoCanUse(OpenEnterpriseAPI())
        actors["Edge Agent"] = Actor("Edge Agent").whoCanUse(Sdk())
        return actors
    }
    
    override class func setUp() async throws {
        mediatorOobUrl = environment["MEDIATOR_OOB_URL"]!
        agentUrl = environment["PRISM_AGENT_URL"]!
        publishedDid = environment["PUBLISHED_DID"] ?? ""
        jwtSchemaGuid = environment["JWT_SCHEMA_GUID"] ?? ""
        anoncredDefinitionGuid = environment["ANONCRED_DEFINITION_GUID"] ?? ""
        apiKey = environment["APIKEY"] ?? ""
        
        try await checkPublishedDid()
        try await checkJwtSchema()
        try await checkAnoncredDefinition()

        TestFramework.logger.logLine()
        TestFramework.logger.info("Mediator", Config.mediatorOobUrl)
        TestFramework.logger.info("Agent", Config.agentUrl)
        TestFramework.logger.info("DID", Config.publishedDid)
        TestFramework.logger.info("JWT Schema", Config.jwtSchemaGuid)
        TestFramework.logger.info("Anoncred Definition", Config.anoncredDefinitionGuid)
        
        // TODO: Get SDK version
        TestFramework.logger.logLine()
        
    }
    
    override class func tearDown() async throws {
    }
    
    private static func checkPublishedDid() async throws {
        let api = OpenEnterpriseAPI.API()
        let isPresent = try await api.isDidPresent(publishedDid)
        if (isPresent) {
            return
        }
        TestFramework.logger.info("DID [\(publishedDid)] not found. Creating a new one.")
        
        let unpublishedDid = try await api.createUnpublishedDid()
        let publishedDid = try await api.publishDid(unpublishedDid.longFormDid)
        let shortFormDid = publishedDid.scheduledOperation.didRef
        
        try await Wait.until(timeout: 60) {
            let did = try await api.getDid(shortFormDid)
            return did.status == "PUBLISHED"
        }
        
        self.publishedDid = shortFormDid
    }
    
    private static func checkJwtSchema() async throws {
        let api = OpenEnterpriseAPI.API()
        let isPresent = try await api.isJwtSchemaGuidPresent(jwtSchemaGuid)
        if (isPresent) {
            return
        }
        TestFramework.logger.info("JWT schema [\(jwtSchemaGuid)] not found. Creating a new one.")
        
        let jwtSchema = try await api.createJwtSchema(author: publishedDid)
        self.jwtSchemaGuid = jwtSchema.guid
    }
    
    private static func checkAnoncredDefinition() async throws {
        let api = OpenEnterpriseAPI.API()
        let isPresent = try await api.isAnoncredDefinitionPresent(anoncredDefinitionGuid)
        if (isPresent) {
            return
        }
        TestFramework.logger.info("Anoncred Definition not found for [\(anoncredDefinitionGuid)]. Creating a new one.")
        
        let anoncredSchema = try await api.createAnoncredSchema(publishedDid)
        let anoncredDefinition = try await api.createAnoncredDefinition(publishedDid, anoncredSchema.guid)
        self.anoncredDefinitionGuid = anoncredDefinition.guid
    }
}

enum ConfigError: Error {
    case PublishedDIDNotFound
}
