/**
 * My BDD Test
 */
component extends="testbox.system.BaseSpec" {

	property name="HTMLOutputDir" default="../../tests/resources/tmp/html";
	property name="JSONOutputDir" default="../../tests/resources/tmp/json";
	property name="XMIOutputFile" default="../../tests/resources/tmp/uml/XMITestFile.uml";

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		structDelete( variables, "docbox" );
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "DocBox", function(){
			beforeEach( function(){
				resetTmpDirectory( expandPath( variables.HTMLOutputDir ) );
				resetTmpDirectory( expandPath( variables.JSONOutputDir ) );
				resetTmpDirectory( expandPath( getDirectoryFromPath( variables.XMIOutputFile ) ) );

				variables.docbox = new docbox.DocBox();
			} );

			it( "Works with single strategy", function(){
				variables.docbox
					.addStrategy(
						"docbox.strategy.api.HTMLAPIStrategy",
						{ outputDir : variables.HTMLOutputDir }
					)
					.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);

				var allClassesFile = variables.HTMLOutputDir & "/allclasses-frame.html";
				expect( fileExists( allClassesFile ) ).toBeTrue(
					"should generate allclasses-frame.html file to list all classes"
				);
			} );

			it( "throws if no strategy is set", function(){
				expect( function(){
					variables.docbox.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);
				} ).toThrow( "StrategyNotSetException" );
			} );

			it( "lets me set my own strategy", function(){
				expect( function(){
					var myDemoStrategy = getMockBox().createStub( extends = "docbox.strategy.AbstractTemplateStrategy" );
					myDemoStrategy.$(
						method      = "run",
						returns     = new docbox.strategy.AbstractTemplateStrategy(),
						callLogging = true
					);
					variables.docbox
						.setStrategy( myDemoStrategy )
						.generate(
							source   = expandPath( "/tests" ),
							mapping  = "tests",
							excludes = "(coldbox|build\-docbox)"
						);

					expect( myDemoStrategy.$once( "run" ) ).toBeTrue( "should execute strategy.run()" );
				} ).notToThrow();
			} );

			it( "Works with multiple strategies", function(){
				variables.docbox
					.addStrategy(
						"docbox.strategy.api.HTMLAPIStrategy",
						{ outputDir : variables.HTMLOutputDir }
					)
					.addStrategy(
						"docbox.strategy.json.JSONAPIStrategy",
						{ outputDir : variables.JSONOutputDir }
					)
					.addStrategy(
						"docbox.strategy.uml2tools.XMIStrategy",
						{ outputFile : variables.XMIOutputFile }
					)
					.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);

				var allClassesFile = variables.HTMLOutputDir & "/allclasses-frame.html";
				expect( fileExists( allClassesFile ) ).toBeTrue(
					"should generate allclasses-frame.html file to list all classes"
				);

				var results = directoryList(
					variables.JSONOutputDir,
					true,
					"name"
				);
				expect( results.len() ).toBeGT( 0 );

				expect( arrayContainsNoCase( results, "overview-summary.json" ) ).toBeTrue(
					"should generate overview-summary.json class index file"
				);
			} );

			it( "Supports strategy aliases", function(){
				variables.docbox
					.addStrategy(
						"HTML",
						{ outputDir : variables.HTMLOutputDir }
					)
					.addStrategy(
						"JSON",
						{ outputDir : variables.JSONOutputDir }
					)
					.addStrategy(
						"XMI",
						{ outputFile : variables.XMIOutputFile }
					)
					.generate(
						source   = expandPath( "/tests" ),
						mapping  = "tests",
						excludes = "(coldbox|build\-docbox)"
					);

				var allClassesFile = variables.HTMLOutputDir & "/allclasses-frame.html";
				expect( fileExists( allClassesFile ) ).toBeTrue(
					"should generate allclasses-frame.html file to list all classes"
				);

				var results = directoryList(
					variables.JSONOutputDir,
					true,
					"name"
				);
				expect( results.len() ).toBeGT( 0 );

				expect( arrayContainsNoCase( results, "overview-summary.json" ) ).toBeTrue(
					"should generate overview-summary.json class index file"
				);
			} );
		} );
	}

	function resetTmpDirectory( directory ){
		// empty the directory so we know if it has been populated
		if ( directoryExists( arguments.directory ) ) {
			directoryDelete( arguments.directory, true );
		}
		directoryCreate( arguments.directory );
	}

}

