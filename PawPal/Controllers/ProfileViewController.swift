//
//  ProfileViewController.swift
//  PawPal
//
//  Created by Hieu Hoang on 12/15/24.
//

import UIKit

struct PetProfile {
    var image: UIImage?
    var name: String
    var type: String
    var age: String
    var characteristics: [String]
    var description: String
}

class ProfileViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var characteristicsStackView: UIStackView!
    @IBOutlet weak var descriptionTextView: UITextView!

    // MARK: - Properties
    var petProfile: PetProfile?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup stack view
        setupCharacteristicsStackView()
        
        // Display pet profile data
        displayProfileData()
    }

    // MARK: - Setup
    private func setupCharacteristicsStackView() {
        characteristicsStackView.axis = .horizontal // or .vertical based on your requirement
        characteristicsStackView.distribution = .fillProportionally
        characteristicsStackView.spacing = 8 // Adjust spacing as needed
    }



    // MARK: - Setup
    func displayProfileData() {
        guard let profile = petProfile else { return }
        
        // Set profile data
        profileImageView.image = profile.image
        nameLabel.text = profile.name
        typeLabel.text = profile.type
        ageLabel.text = "Age: \(profile.age)"
        descriptionTextView.text = profile.description

        // Clear existing characteristics
        characteristicsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add each characteristic as a label in the stack view
        for characteristic in profile.characteristics {
            let label = UILabel()
            label.text = characteristic
            label.textAlignment = .center
            label.backgroundColor = UIColor.systemTeal
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false
            
            // Set padding around text using Insets
            let padding: CGFloat = 8
            let paddedView = UIView()
            paddedView.backgroundColor = UIColor.systemTeal
            paddedView.layer.cornerRadius = 10
            paddedView.clipsToBounds = true
            paddedView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add the label to the padded view
            paddedView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: paddedView.leadingAnchor, constant: padding),
                label.trailingAnchor.constraint(equalTo: paddedView.trailingAnchor, constant: -padding),
                label.topAnchor.constraint(equalTo: paddedView.topAnchor, constant: padding),
                label.bottomAnchor.constraint(equalTo: paddedView.bottomAnchor, constant: -padding)
            ])
            
            // Add the padded view to the stack view
            characteristicsStackView.addArrangedSubview(paddedView)
            
            // Set minimum width and height for each block
            paddedView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            paddedView.widthAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        }
    }


}
