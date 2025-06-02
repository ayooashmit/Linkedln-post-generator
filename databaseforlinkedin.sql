
SET FOREIGN_KEY_CHECKS = 0;

DROP DATABASE IF EXISTS `linkedin_posts`;

CREATE SCHEMA IF NOT EXISTS `linkedin_posts` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

USE `linkedin_posts`;

--  'creators'
DROP TABLE IF EXISTS `creators`;
CREATE TABLE `creators` (
  `creator_id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `linkedin_profile_url` VARCHAR(255) NULL,
  `followers_count` INT NULL,
  PRIMARY KEY (`creator_id`)
);

-- 'posts' 
DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `text` TEXT NOT NULL,
  `engagement` INT NULL,
  `line_count` INT NULL,
  `language` VARCHAR(50) NULL,
  `tags` JSON NULL, 
  `creator_id` INT NULL, -- foreign
  PRIMARY KEY (`id`)
);


ALTER TABLE `posts`
ADD CONSTRAINT `fk_posts_creators`
FOREIGN KEY (`creator_id`)
REFERENCES `creators` (`creator_id`)
ON DELETE SET NULL 
;


INSERT INTO `creators` (`name`, `linkedin_profile_url`, `followers_count`) VALUES
('Alice Smith', 'https://www.linkedin.com/in/alice-smith/', 65000),
('Bob Johnson', 'https://www.linkedin.com/in/bob-johnson/', 12000),
('Charlie Brown', 'https://www.linkedin.com/in/charlie-brown/', 80000);

-- creator_ids
SET @alice_id = (SELECT `creator_id` FROM `creators` WHERE `name` = 'Alice Smith');
SET @bob_id = (SELECT `creator_id` FROM `creators` WHERE `name` = 'Bob Johnson');
SET @charlie_id = (SELECT `creator_id` FROM `creators` WHERE `name` = 'Charlie Brown');


INSERT INTO `posts` (`text`, `engagement`, `line_count`, `language`, `tags`, `creator_id`) VALUES
('Just saw a LinkedIn Influencer with \'Organic Growth\' written in the profile with 65K+ followers claiming that he can help you in growing your platform, copying the posts from other influencers.', 90, 1, 'English', '["Influencer", "Organic Growth"]', @alice_id),
('Jobseekers, this one’s for you.\n Every application, every interview, every follow-up… the pressure is immense.\n And I know what you\'re thinking: Am I not good enough? \n But let me tell you, this isn’t about you or your skills. It’s about a broken system where 60% of applicants never hear back. \n Your mental health is not worth sacrificing for a system that doesn’t acknowledge your worth. \n Please remember, taking care of yourself is the real priority. \n Your dream job will come, but for now, breathe. 🌷', 347, 7, 'English', '["Job Search", "Mental Health"]', @alice_id),
('Looking for jobs on LinkedIn is like online dating: Full of promises, but in the end, you’re just left ghosted.', 109, 1, 'English', '["Job Search", "Online Dating"]', @alice_id),
('LinkedIn scams be like: \'Congratulations, you\'ve been selected for a role you didn’t even apply for!\' \n The catch? Pay Rs. 50,000 for the honor.', 115, 2, 'English', '["Scams"]', @alice_id),
('sapne dekhna achi baat hai,\nlekin job ka sapna dekh ke \'interested\' likhna,\nyeh toh achi baat nahi hai na?', 545, 3, 'Hinglish', '["Job Search", "Sapne"]', @alice_id),
('Next time when I\'ll be reading some LinkedIn Influencer\'s story, I am starting from the last line.\nIf there\'s a link attached to it, it\'s most probably a fake one.\nSaves me time!', 188, 3, 'English', '["Productivity", "Time Management"]', @alice_id),
('Every time I poured my heart into 5-6 rounds of interviews and faced rejection, it felt like a punch in the gut. The sleepless nights, the endless preparation, all for nothing.\n\nBut looking back, I realize it wasn’t nothing. It was the Universe’s way of saying, “Not this one, something better is on the way.”\n\nEvery single time, I’ve been shown why that rejection happened.\n\nDoors I thought I wanted to walk through were shut, only to have the right ones swing open.\n\nThe kind that aligned with my growth, my values, and my happiness.\n\nAt first, it stung. It hurt deeply. But now, when things don’t go as planned, I don’t panic.\n\nI don’t question my worth. I sit back, breathe, and trust. The Universe knows.\n\nI know there\'s another plan waiting. Something bigger, better, and just for me.\n\nTo anyone feeling the weight of rejection: trust that the closed doors are protecting you from something you can’t see right now.\n\nYour path is being cleared for something even more beautiful.', 206, 16, 'English', '["Motivation"]', @alice_id),
('To everyone who\'s still looking for a job...\n\nI see you. I feel you. 💔\n\nEvery rejection email feels like a punch in the gut, and every \'We\'ll get back to you\' sounds more like \'You\'ll never hear from us.\'\n\nBut I want you to know, you\'re not alone in this. 🌸\n\nAccording to a study, 80% of jobseekers struggle with anxiety and self-doubt during their search. It\'s normal to feel lost, but it\'s not the end.\n\nTake breaks, breathe, and remember, this doesn\'t define you. Your worth is not tied to an offer letter. 💥\n\nYour mental health matters more than any job.', 899, 9, 'English', '["Job Search", "Mental Health"]', @alice_id),
('Sometimes, we forget that a company’s brand name doesn’t define someone’s talent. It’s easy to get caught up in the \'big company = big talent\' mindset, but that\'s not always the case.\n\nI’ve had the privilege of working with people from smaller companies (lesser known) who blow me away with their skills and dedication. They don’t need a fancy title or a famous brand behind them to prove their worth.\n\nI\'ve seen the other side too—people in top-tier companies feeling lost, overwhelmed, or stuck, even though the world sees them as \'successful\'.\n\nLet’s stop attaching someone’s value to the company they work for. Freshers especially need to hear this—skills are what matter, not the size of the company behind them.\n\nAt the end of the day, happiness and growth don’t come from a brand name, they come from doing what you love and constantly improving your craft.', 166, 11, 'English', '["Self Improvement", "Career Advice"]', @alice_id),
('So when I left a toxic work environment, I told my manager a simple thing and felt so good 🙂\n\nI just said-\n\n\'Hope your son gets a manager like you.\nI hope that the manager behaves the same way as you did with me.\nThank you.\'\n\nNow tell me 1 thing-\n\nShe always said that she was a great manager.\nWhy will she get offended?\n\nI just told her that I wish her son would get a manager like she was.\n\nIf you felt bad, then that means you were a bad manager and now you know it. 🤦‍♀️\n\nIf you feel good, then take it as a blessing for your son and you\'ll really want someone to treat your son/daughter in the same way.\n\nShe cannot be even angry with me else it\'ll prove that she was not a \'great\' manager.\n\nMuskan - 1\nManager - 0\n\nMuskan -> Aura +100000000\n\n(Fictional message unfortunately :(\n)\n\nHope you all become the people that your sons/daughters will like to work under 🙏\n\nThere are a lot of bad people/things, bring a small change and break the chain :)', 1111, 19, 'English', '["Motivation", "Leadership"]', @alice_id);



INSERT INTO `posts` (`text`, `engagement`, `line_count`, `language`, `tags`, `creator_id`) VALUES
('The pace of innovation in Artificial Intelligence continues to astound. From advanced machine learning algorithms powering recommendation engines to sophisticated neural networks revolutionizing medical diagnostics, AI is no longer a futuristic concept but an integral part of our daily lives. Exploring its ethical implications and the potential for job displacement, alongside its immense benefits, is crucial for responsible development. What are your thoughts on AI\'s most significant societal impact in the next decade?', 380, 7, 'English', '["AI", "Machine Learning", "Future Tech"]', @bob_id),
('Demystifying the intricate world of Blockchain technology requires a fresh perspective. Beyond cryptocurrencies, its decentralized ledger system offers unparalleled transparency and security for supply chain management, digital identities, and even voting systems. Understanding the underlying principles of distributed consensus and cryptographic hashing is key to unlocking its transformative potential across various industries. How do you foresee blockchain reshaping traditional sectors?', 410, 8, 'English', '["Blockchain", "Decentralization", "FinTech"]', @bob_id),
('The evolution of Cybersecurity threats demands constant vigilance and adaptive strategies. From sophisticated phishing attacks targeting individuals to state-sponsored cyber warfare aiming at critical infrastructure, the landscape is complex and ever-changing. Implementing robust security protocols, fostering a culture of cyber awareness, and investing in advanced threat detection systems are paramount for both businesses and individuals in this digital age. What\'s your top tip for staying secure online?', 395, 7, 'English', '["Cybersecurity", "Data Privacy", "Threat Intelligence"]', @bob_id),
('Exploring the vast potential of Quantum Computing is like peering into a new dimension of computational power. Unlike classical computers that rely on bits, quantum computers leverage qubits, enabling them to solve problems currently intractable for even the most powerful supercomputers. While still in its nascent stages, breakthroughs in quantum algorithms promise revolutions in drug discovery, material science, and complex optimization. What specific applications of quantum computing excite you most?', 420, 8, 'English', '["Quantum Computing", "Future Tech", "Computational Science"]', @bob_id),
('Software development methodologies have come a long way, but the core principles of agile and iterative processes remain critical for success. Embracing practices like continuous integration and continuous delivery (CI/CD) ensures faster deployment cycles and higher code quality. Furthermore, understanding design patterns and clean code principles can dramatically improve maintainability and scalability of applications in today\'s fast-paced development cycles. How do you approach project management in tech?', 405, 8, 'English', '["Software Development", "Agile", "DevOps"]', @bob_id),
('The rapid expansion of the Internet of Things (IoT) is creating a seamlessly interconnected world, transforming everything from smart homes to industrial automation. However, this convenience comes with significant challenges, particularly in data privacy and network security. Ensuring robust encryption and secure authentication for every connected device is essential to prevent vulnerabilities and protect sensitive user information. What kind of smart tech integration do you find most impactful?', 390, 7, 'English', '["IoT", "Smart Devices", "Connectivity"]', @bob_id),
('Cloud Computing has fundamentally reshaped how businesses operate, offering unprecedented scalability, flexibility, and cost-efficiency. Whether it\'s Infrastructure as a Service (IaaS), Platform as a Service (PaaS), or Software as a Service (SaaS), the cloud empowers organizations to innovate faster and reach global markets with ease. However, careful consideration of cloud security, data governance, and vendor lock-in is vital for a successful migration and long-term strategy. What are the biggest benefits of cloud adoption you\'ve seen?', 415, 8, 'English', '["Cloud Computing", "SaaS", "Digital Transformation"]', @bob_id),
('The rise of Augmented Reality (AR) and Virtual Reality (VR) is pushing the boundaries of digital interaction, moving beyond flat screens into immersive experiences. From training simulations in complex industries to enhanced retail experiences and collaborative design, these technologies promise to revolutionize how we learn, work, and entertain ourselves. Overcoming challenges in hardware accessibility and content creation will be key to their widespread adoption. Which AR/VR application do you think has the most potential?', 400, 7, 'English', '["Augmented Reality", "Virtual Reality", "Immersive Tech"]', @bob_id),
('Data Science and Analytics are the backbone of modern decision-making, enabling businesses to extract actionable insights from vast datasets. The ability to clean, process, and model data, often using machine learning techniques, provides a competitive edge in understanding market trends, predicting customer behavior, and optimizing operations. Developing strong statistical foundations and proficiency in tools like Python or R are essential for aspiring data professionals. How has data influenced your professional insights?', 425, 8, 'English', '["Data Science", "Analytics", "Big Data"]', @bob_id),
('Navigating the landscape of Open Source technologies offers immense advantages, fostering collaboration, transparency, and rapid innovation. From operating systems like Linux to development frameworks and databases, open source powers much of the digital world. Contributing to open-source projects not only enhances your skills but also strengthens the global tech community. What are your favorite open-source tools or projects and why?', 390, 7, 'English', '["Open Source", "Software Community", "Linux"]', @bob_id);


INSERT INTO `posts` (`text`, `engagement`, `line_count`, `language`, `tags`, `creator_id`) VALUES
('Charlie\'s take on the future of Robotics: It\'s not just about automating factory lines anymore. We are on the cusp of a new era where collaborative robots (cobots) and advanced AI will integrate seamlessly into various aspects of our lives, from healthcare assistance to complex exploration. Understanding the ethical implications of autonomous systems and ensuring human-robot collaboration remains a priority is paramount for societal acceptance and progress.', 370, 7, 'English', '["Robotics", "Automation", "AI Ethics"]', @charlie_id),
('The advancements in Bio-informatics and Health Tech are truly revolutionary, leveraging technology to transform medical research, diagnostics, and patient care. From genomic sequencing and personalized medicine to wearable health trackers and telemedicine platforms, technology is making healthcare more accessible, efficient, and precise. However, ensuring data privacy and interoperability remains a significant challenge that needs robust solutions.', 410, 8, 'English', '["Health Tech", "Bioinformatics", "Digital Health"]', @charlie_id),
('Deciphering the complexities of Network Architecture is crucial in a hyper-connected world. With the advent of 5G, edge computing, and software-defined networking (SDN), designing resilient, scalable, and secure networks has become more critical than ever. Understanding concepts like network segmentation, firewall configurations, and intrusion detection systems is fundamental for any modern IT professional. What trends are you observing in network infrastructure?', 395, 7, 'English', '["Networking", "5G", "Edge Computing"]', @charlie_id),
('Charlie on the evolution of Programming Languages: From the foundational C and Java to the versatile Python and modern JavaScript frameworks, the choice of language heavily influences project efficiency and scalability. Understanding the paradigms – object-oriented, functional, or declarative – helps developers select the right tool for the job and write more robust, maintainable code. What’s your go-to programming language for new projects and why?', 420, 8, 'English', '["Programming", "Coding", "Software Engineering"]', @charlie_id),
('The ethical considerations surrounding Facial Recognition technology are becoming increasingly pertinent in public discourse. While offering benefits for security and convenience, concerns about privacy infringement, bias in algorithms, and potential for surveillance abuse are growing. Developing clear regulatory frameworks and ensuring transparency in algorithm design are essential steps to balance innovation with individual rights. How do we ensure responsible AI development?', 400, 7, 'English', '["AI Ethics", "Facial Recognition", "Privacy"]', @charlie_id),
('Charlie\'s insights into the impact of Big Data on various industries: The sheer volume, velocity, and variety of data being generated today offer unprecedented opportunities for informed decision-making. From personalized marketing campaigns to scientific discoveries and urban planning, Big Data analytics provides a powerful lens into complex systems. However, managing this data effectively, ensuring its quality, and extracting meaningful insights requires specialized skills and robust infrastructure. How has big data impacted your industry?', 415, 8, 'English', '["Big Data", "Data Analytics", "Business Intelligence"]', @charlie_id),
('The transformative power of Generative AI models, such as large language models and image generators, is undeniable. These tools are democratizing content creation, accelerating research, and sparking new forms of creativity. However, challenges related to factual accuracy, potential for misuse, and the concept of originality in AI-generated content demand careful consideration and ongoing development of robust ethical guidelines. What are your thoughts on the creative potential of AI?', 430, 8, 'English', '["Generative AI", "LLMs", "AI Art"]', @charlie_id),
('Charlie discussing the critical role of User Experience (UX) and User Interface (UI) design in technology: A technically brilliant product can fail if it\'s not intuitive and enjoyable to use. Prioritizing user research, iterative prototyping, and continuous feedback loops are essential to create products that truly meet user needs and deliver a seamless experience. Investing in good UX/UI is investing in product success and user satisfaction. What makes a great user experience for you?', 405, 7, 'English', '["UX Design", "UI Design", "Product Development"]', @charlie_id),
('The accelerating shift to serverless architectures marks a significant evolution in cloud-native development. By abstracting away server management, developers can focus solely on writing code, leading to faster deployment, reduced operational overhead, and automatic scaling. Understanding event-driven programming and optimizing function performance are key skills for leveraging this powerful paradigm. What benefits have you seen from adopting serverless?', 390, 7, 'English', '["Serverless", "Cloud Native", "Backend Development"]', @charlie_id),
('Charlie on the crucial importance of a robust DevOps culture: It\'s more than just a set of tools; it\'s a philosophy that breaks down silos between development and operations, fostering collaboration, automation, and continuous improvement. Implementing practices like automated testing, infrastructure as code, and continuous monitoring leads to faster, more reliable software releases and a more stable production environment. How has DevOps transformed your team''s workflow?', 420, 8, 'English', '["DevOps", "Automation", "Software Delivery"]', @charlie_id);



SET FOREIGN_KEY_CHECKS = 1;

/*
SELECT
  p.id AS post_id,
  p.text,
  p.engagement,
  p.language,
  p.tags,
  c.name AS creator_name,
  c.followers_count
FROM
  `posts` AS p
JOIN
  `creators` AS c
ON
  p.creator_id = c.creator_id
ORDER BY
  c.name, p.id;
*/