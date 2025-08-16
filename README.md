### Statistical Exploration of Thermophysical Characteristics in Cheese: Differentiation, Variety Detection, and 
Texture Classification

This report presents a statistical analysis of 89 cheese samples from two commercial manufacturers, each labeled 
with one of four textures: Hard, Pasta Filata, Semi-Hard, and Soft. Each sample was measured on six 
thermophysical properties relevant to classification and production. 
Three research questions were addressed: 
1. **whether thermophysical properties differ by texture**?   MANOVA confirmed significant differences among textures, except between Pasta Filata and Soft.
2. **how many distinct cheese varieties exist based on these measurements**? Clustering techniques 
consistently identified three natural cheese varieties. 
3. **whether texture can be predicted from thermophysical properties**?   Linear Discriminant Analysis achieved 100 percent classification accuracy. 
These results support the use of thermophysical measurements for distinguishing textures, identifying cheese 
varieties, and classifying new samples, valuable tools for quality control and product development. 

The data set includes data from two different manufacturers on 89 cheeses of various types from the four cheese textures, and with nine variables listed in the table below. 
The proposed questions by Dr. Frankenstein’s group allow us to answer the questions using the variables provided.  
  • For the first question, the response variables are the six quantitative thermophysical measurements provided. 
  We could also use manufacturer if we wanted to see if the manufacturer had any effect on the modeling.  
  • For the second question, we will use the thermophysical measurement variables to perform Principal 
  Component Analysis which creates natural groupings in the data. We will also use a method called k-means to 
  also identify the groupings in the data.  
  • For the third question, texture (Hard, Pasta Filata, Semi-hard and Soft) are the response variables and the 
  thermophysical variables are the predictors/explanatory variables. 
<img width="1360" height="478" alt="image" src="https://github.com/user-attachments/assets/4d81e826-65c4-4669-a3ff-2b68a644f93d" />

The results comes out that  
  • **Question 1**: The **MANOVA** provided strong evidence that cheese texture is associated with differences in 
  thermophysical properties. **All textures were significantly different from one another, except for Pasta Filata and 
  Soft**, which appeared statistically similar in their physical profiles. The assumptions were adequately met, 
  supporting the validity of conclusions. Supporting figures, test results, and tables are provided in the Appendix.  
  • **Question 2**: Based on the analysis, there appears to be **three different varieties of cheese** in the dataset. We used 
  an unsupervised learning task because we did not know the true groupings beforehand. We verified that there 
  were three groupings by using **PCA**, **k-means clustering**, and **hierarchical clustering**, which showed each time that 
  there were three natural groupings based on the thermophysical properties. Each cluster can be summarized by the following characteristics:  
  <img width="1201" height="81" alt="image" src="https://github.com/user-attachments/assets/e2a03dee-a619-4d42-a195-4ba2bc97d6c4" />
  
  <img width="750" alt="image" src="https://github.com/user-attachments/assets/c95d321e-f4b2-47dd-baa3-61f144aaae1f" />

  • **Question 3**: The six thermophysical properties of cheese can be used to accurately classify cheese into known 
  texture categories. Specifically, the **LDA model**, a **supervised classifier**, effectively distinguishes between texture 
  types. All model assumptions were reasonably satisfied, and **both cross-validation and final testing confirmed 
  excellent classification performance with no misclassification and 100% accuracy**.  
  <img width="589" height="360" alt="image" src="https://github.com/user-attachments/assets/62044962-33a9-45a4-bb63-83a4edcc99da" />

  
