//
//  WeatherDetailViewController.swift
//  WeatherApp
//
//  Created by Jose Alarcon Chacon on 1/21/19.
//  Copyright © 2019 Pursuit. All rights reserved.
//

import UIKit
class WeatherDetailViewController: UIViewController {
    var currentCity = ""
    var selectedWeatherImage: WeatherData!
    var forecastSelected: WeatherData!
   
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var favorites: UIBarButtonItem!
    @IBAction func favoriteCity(_ sender: UIBarButtonItem) {
        addFavoriteImage()
       let alert = UIAlertController(title: "Seved Image", message: "", preferredStyle: .alert)
        let gotit = UIAlertAction(title: "Got it", style: .default) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(gotit);present(alert, animated: true, completion: nil)
    }
   func addFavoriteImage() {
        if let image = imageView.image {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm;ss"
            let now = dateFormatter.string(from: Date())
            let createdAt = WeatherHelper.dateData(date: now)
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {return print("no image data")}
            let favoriteImage = ImageModel.init(createdAt: createdAt, imageData: imageData)
            WeatherModel.addItem(item: favoriteImage)
        }
    }

    var imageData = [CityImages.HitWrapper] () {
        didSet {
            let image = Int.random(in: 0..<imageData.count)
            ImageHelper.fetchImages(url: imageData[image].largeImageURL) { (appError, image) in
                if let appError = appError {
                    print(appError)
                }
                if let image = image {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        highLabel.text = "High: \(String(forecastSelected.maxTempF))"
        lowLabel.text = "Low: \(String(forecastSelected.minTempF))"
        sunsetLabel.text = "Sunset: \(WeatherHelper.timeData(time: forecastSelected.sunsetISO))"
        sunriseLabel.text = "Sunrise: \(WeatherHelper.timeData(time: forecastSelected.sunriseISO))"
        windspeedLabel.text = "Windspeed: \(String(forecastSelected.windSpeedMPH))"
        precipitationLabel.text = "Inches Precipitation: \(String(forecastSelected.pressureIN))"
        weatherDescriptionLabel.text = "Weather for \(currentCity) is \(forecastSelected.dateTimeISO.dropLast(15))"
       weatherDescription.text = forecastSelected.weather
        
        WeatheAPIClient.getCity(selectedCity: currentCity) { (appError, data) in
            if let appError = appError {
                print(appError)
            }
            if let data = data {
                self.imageData = data
            }
        }
    }
    @IBAction func searchButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
