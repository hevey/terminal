//
//  StdLib.swift
//  Cub
//
//  Created by Louis D'hauwe on 11/12/2016.
//  Copyright © 2016 - 2018 Silver Fox. All rights reserved.
//

import Foundation

public class StdLib {

	private let sources = ["Arithmetic", "Graphics"]

	public init() {

	}

	public func stdLibCode() throws -> String {

		var stdLib = ""

		#if SWIFT_PACKAGE
			
			// Swift packages don't currently have a resources folder
			
			var url = URL(fileURLWithPath: #file)
			url.deleteLastPathComponent()
			url.appendPathComponent("Sources")
			
			let resourcesPath = url.path
			
		#else
			
			let bundle = Bundle(for: type(of: self))

			guard let resourcesPath = bundle.resourcePath else {
				throw StdLibError.resourceNotFound
			}
			
		#endif
		
		for sourceName in sources {

			let resourcePath = "\(resourcesPath)/\(sourceName).cub"

			let source = try String(contentsOfFile: resourcePath, encoding: .utf8)
			stdLib += source

		}
		
		return stdLib
	}
	
	func registerExternalFunctions(_ runner: Runner) {
		
		let isNumberDoc = """
						Checks if the value is a number.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is a number, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isNumberDoc, name: "isNumber", argumentNames: ["value"], returns: true) { (arguments, callback) in

			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isNumber))
			
		}
		
		let isStringDoc = """
						Checks if the value is a string.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is a string, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isStringDoc, name: "isString", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isString))
			
		}
		
		let isBoolDoc = """
						Checks if the value is a boolean.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is a boolean, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isBoolDoc, name: "isBool", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isBool))
			
		}
		
		let isArrayDoc = """
						Checks if the value is an array.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is an array, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isArrayDoc, name: "isArray", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isArray))
			
		}
		
		let isStructDoc = """
						Checks if the value is a struct.
						- Parameter value: the value to check the type of.
						- Returns: true if the value is a struct, false otherwise.
						"""
		
		runner.registerExternalFunction(documentation: isStructDoc, name: "isStruct", argumentNames: ["value"], returns: true) { (arguments, callback) in
			
			guard let value = arguments["value"] else {
				_ = callback(.bool(false))
				return
			}
			
			_ = callback(.bool(value.isStruct))
			
		}
		
		let dateByAddingDoc = """
						Add a specific amount of a date unit to a given date.

						Example:
						myDate = currentDate()
						tomorrowThisTime = dateByAdding(1, "day", myDate)

						- Parameter value: the number that you want to add to the given date, in the given unit.
						- Parameter unit: a string that represents a date unit. One of the following values: "second", "minute", "hour", "day", "month", "year"
						- Parameter date: a number that represents a date.
						- Returns: a number representing the given date, having added the value in the specified unit.
						"""
		
		runner.registerExternalFunction(documentation: dateByAddingDoc, name: "dateByAdding", argumentNames: ["value", "unit", "date"], returns: true) { (arguments, callback) in
			
			guard case let .number(value)? = arguments["value"],
				case let .string(unit)? = arguments["unit"],
				case let .number(dateString)? = arguments["date"] else {
				_ = callback(.number(0))
				return
			}
			
			let date = Date(timeIntervalSince1970: dateString)

			let intValue = Int(value)
			
			let componentMapping: [String: Calendar.Component] = ["second": .second,
																  "minute": .minute,
																  "hour": .hour,
																  "day": .day,
																  "month": .month,
																  "year": .year]

			guard let component = componentMapping[unit] else {
				_ = callback(.number(0))
				return
			}
			
			guard let newDate = Calendar.current.date(byAdding: component, value: intValue, to: date) else {
				_ = callback(.number(0))
				return
			}
			
			_ = callback(.number(newDate.timeIntervalSince1970))

		}
		
		let currentDateDoc = """
							Get the current date and time, represented as a number.
							- Returns: a number representing the current date and time.
							"""
		
		runner.registerExternalFunction(documentation: currentDateDoc, name: "currentDate", argumentNames: [], returns: true) { (arguments, callback) in
			_ = callback(.number(Date().timeIntervalSince1970))
		}
		
		let dateFromFormatDoc = """
							Get a date (represented as a number), from a string in a specified format.

							Example:
							myDate = dateFromFormat("2012-02-20", "yyyy-MM-dd")

							- Parameter dateString: a date in a string format.
							- Parameter format: the format that the given date string is in.
							- Returns: a date.
							"""
		
		runner.registerExternalFunction(documentation: dateFromFormatDoc, name: "dateFromFormat", argumentNames: ["dateString", "format"], returns: true) { (arguments, callback) in
			
			guard case let .string(dateString)? = arguments["dateString"], case let .string(format)? = arguments["format"] else {
				_ = callback(.number(0))
				return
			}
			
			let formatter = DateFormatter()
			formatter.dateFormat = format
			
			if let timeInterval = formatter.date(from: dateString)?.timeIntervalSince1970 {
				_ = callback(.number(timeInterval))
			} else {
				_ = callback(.number(0))
			}
			
		}
		
		let formattedDateDoc = """
							Get a formatted date (a string) from a date (represented as a number) in a specified format.

							Example:
							myDate = currentDate()
							myDateString = formattedDate(myDate, "yyyy-MM-dd")

							- Parameter date: a number representing a date.
							- Parameter format: the format to get the date in.
							- Returns: a string of the given date, formatted.
							"""
		
		runner.registerExternalFunction(documentation: formattedDateDoc, name: "formattedDate", argumentNames: ["date", "format"], returns: true) { (arguments, callback) in

			guard case let .number(timeInterval)? = arguments["date"], case let .string(format)? = arguments["format"] else {
				_ = callback(.number(0))
				return
			}
			
			let formatter = DateFormatter()
			formatter.dateFormat = format
			
			let date = Date(timeIntervalSince1970: timeInterval)
			
			_ = callback(.string(formatter.string(from: date)))
			
		}
		
		// Can't support the randomNumber command on Linux at the moment,
		// since arc4random_uniform is not available.
		#if !os(Linux)
		
		let randomNumberDoc = """
							Get a random number.

							Example:
							myDiceRoll = randomNumber(1, 6)

							- Parameter min: minimum number.
							- Parameter max: maximum number.
							- Returns: a random number.
							"""
		
		runner.registerExternalFunction(documentation: randomNumberDoc, name: "randomNumber", argumentNames: ["min", "max"], returns: true) { (arguments, callback) in
			
			func randomInt(min: Int, max: Int) -> Int {
				return min + Int(arc4random_uniform(UInt32(max - min + 1)))
			}
			
			guard case let .number(min)? = arguments["min"], case let .number(max)? = arguments["max"] else {
				let randomNumber = NumberType(arc4random_uniform(1))
				
				_ = callback(.number(randomNumber))
				return
			}
			
			_ = callback(.number(NumberType(randomInt(min: Int(min), max: Int(max)))))
			
		}
		
		#endif

		// Can't support the format command on Linux at the moment,
		// since String does not conform to CVarArg.
		#if !os(Linux)

		let formatDoc = """
							Get a formatted string with an argument.

							Example:
							formattedNumber = format("%.f", 1.0) // "1"

							- Parameter input: a string template.
							- Parameter arg: the argument to insert in the template.
							- Returns: a formatted string.
							"""
		
		runner.registerExternalFunction(documentation: formatDoc, name: "format", argumentNames: ["input", "arg"], returns: true) { (arguments, callback) in
			
			var arguments = arguments
			
			guard let input = arguments.removeValue(forKey: "input") else {
				_ = callback(.string(""))
				return
			}
			
			guard case let .string(inputStr) = input else {
				_ = callback(.string(""))
				return
			}
			
			let otherValues = arguments.values
			
			var varArgs = [CVarArg]()
			
			for value in otherValues {
				
				switch value {
				case .bool:
					break
				case .number(let n):
					varArgs.append(n)
				case .string(let str):
					varArgs.append(str)
				case .struct:
					break
				case .array:
					break
				}
				
			}
			
			let output = String(format: inputStr, arguments: varArgs)
			
			_ = callback(.string(output))
			return
		}
	
		#endif

	}

	enum StdLibError: Error {
		case resourceNotFound
	}

}
